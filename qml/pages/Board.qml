
import QtQuick 2.0
import Sailfish.Silica 1.0

import io.thp.pyotherside 1.2



Page {

    width: Screen.width; height: Screen.height;


    anchors.fill: parent

    Column {

        anchors.fill: parent;
        spacing: 25

        Row {

            width: parent.width;

            IconButton {
               width: (parent.width - parent.height) / 2;
               icon.source: "image://theme/icon-m-back"
               onClicked: console.log("Previous!")
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
            width: parent.width
            height: 650
        }


        SlideshowView {
            id: view
            width: parent.width
            height: 100
            itemWidth: width / 2
            onCurrentIndexChanged: {py.call('board.getGame', [view.currentIndex], goban.setGoban)}

            model: 5
            delegate: Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: Theme.primaryColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium

                width: view.itemWidth
                height: view.height
                    text: "Problem " + index

            }
        }
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
            })

            setHandler('log', function (content) {
                console.log(content);
            });

            call('board.setPath', [pythonpath]);
            call('board.loadBoard', ["easy.sgf"], function (result) {
                console.log(result + " problems found in the file")
                view.model = result
                call('board.getGame', [0], goban.setGoban);
            });

        }
    }

}
