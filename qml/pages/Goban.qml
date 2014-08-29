import QtQuick 2.0

import "../javascript/goban_util.js" as Actions

Item {

    /**
     * This property represent a case size on the board.
     * The value is calculated at initialization, and depends on the goban size.
     */
    property int caseSize

    /**
     * Booleans flags telling if the board is limited in each directions
     */
    property bool limitTop: true;
    property bool limitBottom: true;
    property bool limitLeft: true;
    property bool limitRight: true;

    /*
     * The current color to play :
     * - true for white
     * - false for black
     */
    property bool currentPlayer: true;

    property variant tree;

    /*
     * Start the game.
     *
     * Initialize the board with the stones, and set player color.
     */
    function start() {

        currentPlayer = true;

        for (var i = 0; i < goban.rows * goban.columns; i++) {
            repeater.itemAt(i).remove(false);
        }

        var initial

        i = 0;

        while (tree[i].AW === undefined && tree[i].AB === undefined) {
            i++;
        }

        initial = tree[i]

        var aw = initial.AW;
        if (aw !== undefined) {
            aw.forEach(function (pos) {
                goban.getItemAt(pos[0], pos[1]).put(currentPlayer, false);
//                Actions.addPiece(pos[0] + (pos[1] * goban.columns), goban, currentPlayer, false, true, true);
            });
        }

        var ab = initial.AB;
        if (ab !== undefined) {
            ab.forEach(function (pos) {
                goban.getItemAt(pos[0], pos[1]).put(!currentPlayer, false);
//                Actions.addPiece(pos[0] + (pos[1] * goban.columns), goban, !currentPlayer, false, true, true);
            });
        }
    }

    function setGoban(ret) {

        limitTop = ret.side.TOP;
        limitBottom = ret.side.BOTTOM;
        limitLeft = ret.side.LEFT;
        limitRight = ret.side.RIGHT;

        goban.columns = ret.size[0]
        goban.rows = ret.size[1]


        var maxWidth = width / ret.size[0]
        var maxHeight = height / ret.size[1]

        if (maxWidth > maxHeight)  {
            caseSize = maxHeight;
        } else {
            caseSize = maxWidth;
        }

        /*
         * Put the initials stones
         */
        tree = ret.tree;
        start();
    }

    /**
     * Handle a click on the goban.
     */
    function clickHandler(index) {

        if ( (!limitLeft && Actions.isFirstCol(index, goban.columns))
          || (!limitRight && Actions.isLastCol(index, goban.columns))
          || (!limitTop && Actions.isFirstRow(index, goban.columns))
          || (!limitBottom && Actions.isLastRow(index, goban.columns, goban.rows)) ) {

            return;
        }

        if (Actions.addPiece(index, goban, currentPlayer, true, false, false)) {
            currentPlayer = !currentPlayer;
        }

    }

    /**
     * Background
     */
    Image {
        width: goban.width + (caseSize / 2); height: goban.height + (caseSize / 2);
        source: "../content/gfx/board.png"
        anchors.centerIn: goban
    }

    /*
     * Horizontal lines
     */
    Repeater {
        model: goban.rows

        Rectangle {

            x: goban.x + (caseSize / 2)

            y: goban.y + (caseSize / 2) + (index * caseSize)

            width: goban.width - caseSize;

            color: "black"

            visible: (!((index === goban.rows - 1 && !limitBottom) || (index === 0 && !limitTop)))

            height: 1

        }
    }

    /*
     * Verticals lines
     */
    Repeater {
        model: goban.columns

        Rectangle {

            x: goban.x + (caseSize / 2) + (index * caseSize)

            y: goban.y + (caseSize / 2)

            height: goban.height - caseSize;

            color: "black"

            width: 1

            visible: (!((index === goban.columns - 1 && !limitRight) || (index === 0 && !limitLeft)));
        }
    }

    /*
     * The grid for the game.
     */
    Grid {
        id: goban
        anchors.centerIn: parent
        columns: 0
        rows : 0
        spacing: 0

        function getItemAt(x, y) {
            return repeater.itemAt(x + y * columns)
        }

        function getElementAtIndex(index) {
            return repeater.itemAt(index);
        }

        Repeater {
            model: goban.columns * goban.rows
            id : repeater

            Point{
                width: caseSize; height: caseSize
                id : piece

                MouseArea {

                    id: interactiveArea
                    anchors.fill: parent
                    onClicked: clickHandler(index);
                }

            }
        }
    }
}
