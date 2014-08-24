import QtQuick 2.0

import "../actions.js" as Actions

Item {

    property string type: "";

    function getImageForType() {
        if ("" === type) {
            return ""
        }

        return "../content/gfx/" + type + ".png"
    }

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
