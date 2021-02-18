import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

import io.thp.pyotherside 1.3

Item {

    //width: Screen.width; height: Screen.height;

    anchors.fill: parent

    id : board;

    Row {
        id: buttons
        width: parent.width;
        height: Theme.itemSizeMedium
        spacing: Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter

        IconButton {
           width: parent.width / 3
           anchors.verticalCenter: parent.verticalCenter
           icon.source: "image://theme/icon-m-back"
           onClicked: goban.undo();
        }

        IconButton {
           id: bwbutton
           width: parent.width / 3
           anchors.verticalCenter: parent.verticalCenter
           icon.fillMode: Image.PreserveAspectFit
           icon.source: "image://theme/icon-s-clear-opaque-background?" + (goban.currentPlayer ? "#ffffff":"#000000")
           icon.anchors.centerIn: bwbutton
           //icon.source: "../content/gfx/" + (goban.currentPlayer ? "white":"black") + ".png"
           scale: 1.3
           onClicked: goban.showHint();
        }

        IconButton {
           width: parent.width / 3
           anchors.verticalCenter: parent.verticalCenter
           icon.source: "image://theme/icon-m-refresh"
           onClicked: goban.start()
        }
    }
    Separator {
         horizontalAlignment: Qt.AlignHCenter
         width: parent.width - Theme.horizontalPageMargin
         color: Theme.secondaryHighlightColor
         anchors.top: buttons.bottom
     }

    Column {

        id : column;
        anchors.centerIn: parent
        width: parent.width
        height: parent.height - buttons.height - view.height

        Goban {
            id: goban
            width: parent.width - Theme.horizontalPageMargin
            //height: column.height - (buttons.height + view.height) - (sep.height * 2) - Theme.paddingLarge
            height: column.height
            onCompletedLevel: {
                overlay.source = status ? "image://theme/icon-s-decline?red" : "image://theme/icon-s-checkmark?green"
            }
        }
    }

    Separator {
        id: sep
        horizontalAlignment: Qt.AlignHCenter
        width: parent.width - Theme.horizontalPageMargin
        color: Theme.secondaryHighlightColor
        anchors.bottom: view.top
    }

    SlideshowView {
        id: view
        width: parent.width
        anchors.bottom: parent.bottom
        //height: 200
        height: Theme.itemSizeMedium
        itemWidth: width - Theme.horizontalPageMargin
        //itemWidth: width
        //Component.onCompleted: {
        //  if ( conf.problemIdx !== 0 )
        //    py.call('board.getGame', [conf.problemIdx], goban.setGoban)
        //}
        onCurrentIndexChanged: {
            conf.problemIdx = currentIndex ; conf.sync();
            py.call('board.getGame', [currentIndex], goban.setGoban)
        }

        model: 1
        delegate: Text {
            id: problem
            Icon {
              id: leftbutton;
              anchors.left: parent.left;
              anchors.verticalCenter: parent.verticalCenter;
              source: "image://theme/icon-m-enter-accept"
              rotation: 180
              opacity: ( view.currentIndex === 0 ) ? 0.2 : 0.8
            }
            horizontalAlignment: Text.AlignHCenter;
            verticalAlignment: Text.AlignVCenter;

            color: Theme.primaryColor;
            font.family: Theme.fontFamily;
            font.pixelSize: Theme.fontSizeMedium;

            width: view.itemWidth;
            height: view.height;
            text: "Problem " + (index + 1) + " of " + ( view.count );
            Icon {
              id: rightbutton
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter;
              source: "image://theme/icon-m-enter-accept"
              opacity: ( view.currentIndex === view.count ) ? 0.2 : 0.8
            }
        }
    }

    Image {
        id: overlay
        opacity: goban.completed ? 1 : 0
        anchors {
            centerIn:parent
        }
        fillMode: Image.PreserveAspectFit
        scale: 8
        Behavior on opacity { NumberAnimation { duration: 500 } }
    }

    function loadBoard(path) {
        py.loadBoard(path);
    }

    Python {
        id:py
        Component.onCompleted: {
            var pythonpath = Qt.resolvedUrl('../python').substr('file://'.length);
            addImportPath(pythonpath);
            console.log(pythonpath);

            importModule('board', function() {
                console.log('module loaded');
                console.log('Python version: ' + pythonVersion());
            });

            setHandler('log', function (content) {
                console.log(content);
            });

            if (conf.gameFileName === "easy.sgf") {
                call('board.setPath', [pythonpath]);
                call('board.loadBoard', ["easy.sgf"], function (result) {
                    console.log(result + " problems found in the file");
                    view.model = result
                    if ( conf.problemIdx ) {
                        console.log("loading problem no " + conf.problemIdx );
                        call('board.getGame', [conf.problemIdx], goban.setGoban);
                    } else {
                        console.log("loading first problem: " + conf.problemIdx );
                        call('board.getGame', [0], goban.setGoban);
                    }
                });
            } else {
                call('board.loadBoard', [conf.gameFile], function (result) {
                    console.log(result + " problems found in the file");
                    view.model = result
                    if ( conf.problemIdx ) {
                        console.log("loading problem no " + conf.problemIdx );
                        call('board.getGame', [conf.problemIdx], goban.setGoban);
                    } else {
                        console.log("loading first problem: " + conf.problemIdx );
                        call('board.getGame', [0], goban.setGoban);
                    }
                });
            }
        }

        function loadBoard(path) {
            call('board.loadBoard', [path], function (result) {
                console.log(result + " problems found in the file");
                view.model = result
                if ( conf.problemIdx ) {
                    console.log("loading problem no " + conf.problemIdx );
                    call('board.getGame', [conf.problemIdx], goban.setGoban);
                } else {
                    console.log("loading first problem: " + conf.problemIdx );
                    call('board.getGame', [0], goban.setGoban);
                }
            });
        }
    }

    function showHint() {
        goban.showHint();
    }

}
