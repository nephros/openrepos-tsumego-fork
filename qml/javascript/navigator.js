.pragma library

function getCurrentAction(path, tree) {

    var way = tree;
    var ended = false;

    /*
     * Get the action pointed by the path.
     */
    path.forEach( function(element, index, array) {
        if (!ended && element < way.length) {
            way = way[element];
        } else {
            ended = true;
        }
    });

    if ( !ended ) {
        return way;
    } else {
        return undefined;
    }

}

function checkAction(path, tree, player, playedPosition) {

    var way = getCurrentAction(path, tree);
    var pathIndex;

    if (Array.isArray(way)) {
        /*
         * We have choice between different possibilities.
         * We check each of them to get the player action.
         */
        if (way.some( function(element, index, array) {

            /*
             * Increment the path to the next position, and check the expected
             * result.
             */
            path.push(index);
            var next = getCurrentAction(path, tree)[0];

            console.log( next );

            var expectedIndex;
            if (player) {
                expectedIndex = next.W[0];
                console.log("W", next.W);
            } else {
                expectedIndex = next.B[0];
                console.log("B", next.B);
            }

            if (playedPosition === expectedIndex) {
                path.push(0);
                return true;
            }

            /*
             * The position was not the expected one. Restore the path to the
             * original one.
             */
            path.pop();
            return false;

        })) {
            /*
             * We got the rigth action. Now, get the next position in the path.
             */
            console.log("Good !!");
            pathIndex = path.length - 1;
            path[pathIndex] = path[pathIndex] + 1;
            return path;
        } else {
            /*
             * The played position does not match the recorded game.
             */
            return undefined;
        }

    } else {

        /*
         * We only have one possibility, return it.
         */
        console.log("Single result", way);

        var move;
        if (player) {
            move = way.W[0];
        } else {
            move = way.B[0];
        }

        if (move === playedPosition) {
            console.log("Good !!", path);
            pathIndex = path.length - 1;
            path[pathIndex] = path[pathIndex] + 1;
            return path;
        } else {
            return undefined;
        }
    }

}

function play(path, tree, player, addPiece) {

    var way = getCurrentAction(path, tree);
    var pathIndex;

    if (Array.isArray(way)) {

    } else {

        var move;
        if (!player) {
            move = way.W[0];
        } else {
            move = way.B[0];
        }
        pathIndex = path.length - 1;
        path[pathIndex] = path[pathIndex] + 1;
        addPiece(move, path);
    }
}

function undo(path) {
    var way = getCurrentAction(path, tree);

}
