
import QtQuick 2.0
import Sailfish.Silica 1.0


import io.thp.pyotherside 1.2



Page {

    width: Screen.width; height: Screen.height;


    anchors.fill: parent

    Column {

        width:parent.width
        height: parent.height

        spacing: 2
//        Row {

//            height: 60

//            //anchors.horizontalCenter: parent.horizontalCenter
//            Repeater {
//                model: 3
//                Rectangle {
//                    width: 100; height: 40
//                    border.width: 1
//                    color: "yellow"
//                }
//            }
//        }


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
                width: view.itemWidth
                height: view.height
                    text: "Level " + index
                    color: "white"

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
