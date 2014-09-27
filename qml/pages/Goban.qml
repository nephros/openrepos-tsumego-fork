import QtQuick 2.0

import "../javascript/goban_util.js" as Actions
import "../javascript/navigator.js" as TreeNavigator

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

    property bool completed: false;

    /*
     * The current color to play :
     * - true for white
     * - false for black
     */
    property bool currentPlayer: true;

    property bool initialPlayer: true;

    property bool freePlay: false;

    /**
     * The game tree.
     */
    property variant tree;

    /**
     * Path in the tree.
     */
    property variant path;

    /*
     * History for cancelling a move.
     */
    property variant history;

    /*
     * Start the game.
     *
     * Initialize the board with the stones, and set player color.
     */
    function start() {

        completed = false;

        for (var i = 0; i < goban.rows * goban.columns; i++) {
            repeater.itemAt(i).remove(false);
        }

        var initial;
        currentPlayer = initialPlayer;

        i = 0;

        while (tree[i].AW === undefined && tree[i].AB === undefined) {
            i++;
        }

        initial = tree[i];
        history = [];
        path = [i + 1];

        var aw = initial.AW;
        if (aw !== undefined) {
            aw.forEach(function (pos) {
                goban.itemAt(pos).put(true, false);
            });
        }

        var ab = initial.AB;
        if (ab !== undefined) {
            ab.forEach(function (pos) {
                goban.itemAt(pos).put(false, false);
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

        initialPlayer = (ret.current_player === 'W');
        console.log(ret.current_player);

        /*
         * Put the initials stones
         */
        tree = ret.tree;
        start();
    }

    /*
     * Undo the last move.
     */
    function undo() {
        if (history.length === 0) {
            return;
        }

        var currentHistory = history;

        var actions = currentHistory.pop();
        actions.reverse();

        actions.forEach(function (x) {
            Actions.undo(goban, x);
            currentPlayer = x.player;
            path = x.path;
        });

        history = currentHistory;
    }

    /**
     * Handle a click on the goban.
     */
    function clickHandler(index) {

        if (completed) {
            return;
        }

        if ( (!limitLeft && Actions.isFirstCol(index, goban.columns))
          || (!limitRight && Actions.isLastCol(index, goban.columns))
          || (!limitTop && Actions.isFirstRow(index, goban.columns))
          || (!limitBottom && Actions.isLastRow(index, goban.columns, goban.rows)) ) {

            return;
        }

        var step = Actions.addPiece(index, goban, currentPlayer, true, false, false);

        if (step !== undefined) {


            /*
             * Update the path.
             */
            var currentPosition = path[path.length - 1];
            step.path = path;
            var action = TreeNavigator.checkAction(path, tree, currentPlayer, index);
            path = action;


            /*
             * Update the history with the last move.
             */
            var currentHistory = history;
            var actions = [step];


            if (action === undefined) {
                /*
                 * Switch to variation mode
                 */
            } else {
                if (TreeNavigator.getCurrentAction(action, tree) === undefined) {
                    console.log("Level completed!");
                    completed = true;
                    return;
                } else {
                    /*
                     * Play the openent move.
                     */

                    TreeNavigator.play(action, tree, currentPlayer, function(x, newPath) {
                        console.log(x);
                        var oponentAction = Actions.addPiece(x, goban, !currentPlayer, true, false, false)
                        oponentAction.path = path;
                        path = newPath;
                        actions.push(oponentAction);
                    });

                }

            }
            currentHistory.push(actions);
            history = currentHistory;

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

        function itemAt(pos) {
            return repeater.itemAt(pos);
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
