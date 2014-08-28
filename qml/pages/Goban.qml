import QtQuick 2.0

import "../actions.js" as Actions

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
            });
        }

        var ab = initial.AB;
        if (ab !== undefined) {
            ab.forEach(function (pos) {
                goban.getItemAt(pos[0], pos[1]).put(!currentPlayer, false);

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

        var point = repeater.itemAt(index);
        var elementType = point.getType();

        if (elementType !== "") {
            return;
        }

        var neighbors = Actions.getNeighbors(index, goban.columns, goban.rows);

        function isPlayer(x) {
            return repeater.itemAt(x).getType() === (currentPlayer ? "white" : "black");
        }

        function isOponnent(x) {
            return repeater.itemAt(x).getType() === (currentPlayer ? "black" : "white");
        }

        function freeOrChain(x) {
            var pointType = repeater.itemAt(x).getType();
            return pointType === "" || pointType === (currentPlayer ? "white" : "black");
        }

        if (neighbors.length !== 0) {

            var somethingToRemove = false;

            point.put(currentPlayer, true);

            /*
             * Check for pieces to remove.
             */
            neighbors.filter(isOponnent).forEach(function(neighbor) {

                var piecesToRemove = Actions.getChainToRemove(neighbor, repeater, goban.columns, goban.rows, isOponnent);
                if (piecesToRemove.length !== 0) {
                    somethingToRemove = true;
                }
                piecesToRemove.forEach(function(x) {
                    repeater.itemAt(x).remove(true);
                })
            });

            /*
             * Check for suicide.
             */
            if (!somethingToRemove) {
                var suicides = Actions.getChainToRemove(index, repeater, goban.columns, goban.rows, isPlayer);
                if (suicides.length !== 0) {
//                    suicides.forEach(function(x) {
//                        repeater.itemAt(x).remove(true);
//                    });
                    point.remove(false);
                    currentPlayer = !currentPlayer;
                }

            }

            /*
             * Remove the marks in the cases.
             *
             * The call to getChainToRemove add marks on the cases in order to
             * prevent infinite looping. We need to clean the cases before any new
             * click.
             *
             * We do not need to remove them before as we are not filtering the
             * same pieces.
             */
            for (var i = 0; i < goban.columns * goban.rows; i++) {
                repeater.itemAt(i).mark = false;
            }
        }
        currentPlayer = !currentPlayer;

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
