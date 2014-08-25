import QtQuick 2.0

Item {

    property string type: "";
    property alias piece_scale: piece.scale;

    function getImageForType() {
        if ("" === type) {
            return ""
        }
        return "../content/gfx/" + type + ".png"
    }

    function init(initType) {
        type = initType;
        piece.opacity = 1;
        piece.scale = 1;

    }

    states: [
        State {
            name: "shown"
            PropertyChanges  { target: piece; opacity:1 }
        }, State {
            name: "remove"
            onCompleted: type = "";
        }
    ]

    transitions: [
        Transition {
            to: "remove"
            NumberAnimation {
                targets: piece;
                property: "opacity";
                from: 1;
                to: 0
                duration: 500;
            }
        },
        Transition {
            to: "shown"
            PropertyAnimation {
                target: piece;
                property: "scale";
                from: 0;
                to: 1
                easing.type: Easing.OutBack
            }
        }
    ]

    MouseArea {

        id: interactiveArea
        anchors.fill: parent
        onClicked: clickHandler(index);
    }

    Image {
        id: piece
        anchors.fill: parent
        source: getImageForType();
    }
}
