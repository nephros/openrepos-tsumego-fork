
import QtQuick 2.0
import Sailfish.Silica 1.0

import io.thp.pyotherside 1.3

Item {

    //width: Screen.width; height: Screen.height;

    anchors.fill: parent

    id : board;

    Column {

        id : column;
        anchors.fill: parent;
        spacing: 25

        Row {

            id: row
            width: parent.width;

            IconButton {
               width: (parent.width - parent.height) / 2;
               icon.source: "image://theme/icon-m-back"
               onClicked: goban.undo();
            }

            Image {
               width: parent.height;
               source: "../content/gfx/" + (goban.currentPlayer ? "white":"black") + ".png"
               height: parent.height;
               scale: 0.5
            }

            IconButton {
               width: (parent.width - parent.height) / 2;
               icon.source: "image://theme/icon-m-refresh"
               onClicked: goban.start()
            }
        }

        Goban {
            id:goban
            width: parent.width;
            height: column.height - (row.height + view.height);
            onCompletedLevel: {
                overlay.text = status ? "X" : "✓";
                overlay.color = status ? "red" : "green" ;
            }
        }

        SlideshowView {
            id: view
            width: parent.width
            //height: 200
            height: Theme.itemSizeLarge
            //height: Theme.iconSizeMedium
            //itemWidth: width - Theme.horizontalPageMargin
            itemWidth: width
            onCurrentIndexChanged: {
                py.call('board.getGame', [view.currentIndex], goban.setGoban)
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
                }
            }
        }
    }

    Text {
        id: overlay
        opacity: goban.completed ? 1 : 0
        anchors {
            centerIn:parent
        }
        font.family: Theme.fontFamily;
        font.pixelSize: goban.height;

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

            call('board.setPath', [pythonpath]);
            call('board.loadBoard', ["easy.sgf"], function (result) {
                console.log(result + " problems found in the file");
                view.model = result
                call('board.getGame', [0], goban.setGoban);
            });
        }

        function loadBoard(path) {
            call('board.loadBoard', [path], function (result) {
                console.log(result + " problems found in the file");
                view.model = result
                call('board.getGame', [0], goban.setGoban);
            });
        }
    }

    function showHint() {
        goban.showHint();
    }

}
