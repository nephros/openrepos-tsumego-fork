.pragma library

/**
 * Check if the case on the grid belongs to the first column.
 */
function isFirstCol(index, cols) {
    return index % cols == 0;
}

/**
 * Check if the case on the grid belongs to the last column.
 */
function isLastCol(index, cols) {
    return  index % cols == cols - 1;
}

/**
 * Check if the case on the grid belongs to the first row
 */
function isFirstRow(index, cols) {
    return index < cols;
}

/**
 * Check if the case on the grid belongs to the last row.
 */
function isLastRow(index, cols, rows) {
    return cols * (rows - 1) <= index;
}

/**
 * Get all the neighbors for a given position.
 */
function getNeighbors(index, cols, rows) {

    var neighbors = [];
    if (!isFirstCol(index, cols)) {
        neighbors.push(index - 1)
    }

    if (!isLastCol(index, cols)) {
        neighbors.push(index + 1)
    }

    if (!isFirstRow(index, cols)) {
        neighbors.push(index - cols)
    }

    if (!isLastRow(index, cols, rows)) {
        neighbors.push(index + cols)
    }

    return neighbors;
}

function getChainToRemove(index, grid, filter) {

    var piecesToCheck = [];
    var piecesToRemove = [];

    /*
     * filter wich keep only free places.
     */
    function freePlaces(x) {
        return grid.getElementAtIndex(x).getType() === "";
    }

    var piece = index;
    while (piece !== undefined) {

        /* if the case has already been marked, do not check it again.
         */
        if (!grid.getElementAtIndex(piece).mark) {
            grid.getElementAtIndex(piece).mark = true;
            piecesToRemove.push(piece);

            var neighbors = getNeighbors(piece, grid.columns, grid.rows);

            if (neighbors.length !== 0) {
                /*
                 * If the place has liberty, return empty list.
                 */
                if (neighbors.some(freePlaces)) {
                    return [];
                }

                /*
                 * Now update the check list.
                 */
                neighbors.filter(filter).forEach(function(x) {
                    piecesToCheck.push(x)
                });

            }
        } else {
            /*
             * The piece may have been marked outside of this call.
             * (We try to check chain in each direction, and return as soon as
             * we find an empty place).
             * If the piece is marked, but does not belongs to the piecesToRemove,
             * we assume the piece is connected to a living chain, and
             * subsequently this chain too.
             */
            if (! piecesToRemove.some(function(x) { return x === piece})) {
                return [];
            }
        }

        piece = piecesToCheck.pop();
    }
    return piecesToRemove;

}

/**
 * Add a new stone on the goban.
 *
 * Check if there are dead chained and remove them from the goban.
 *
 * index(int):          the index where put the stone.
 * grid(object):        the grid where to put the stone:
 *  - grid.rows:        number of rows in the grid
 *  - grid.columns:     number of columes in the grid
 *  - grid.getElementAtIndex(index) should return the stone a the given index
 * currentPlayer(bool): player color
 * animation(bool):     should we add animation on the goban
 * allowSuicide(bool):  if suicide an autorized action
 *
 * return true if the movement has been allowed.
 */
function addPiece(index, grid, currentPlayer, animation, allowSuicide, allowOveride) {

    var point = grid.getElementAtIndex(index);
    var elementType = point.getType();

    if (!allowOveride && elementType !== "") {
        return false;
    }

    var neighbors = getNeighbors(index, grid.columns, grid.rows);

    function isPlayer(x) {
        return grid.getElementAtIndex(x).getType() === (currentPlayer ? "white" : "black");
    }

    function isOponnent(x) {
        return grid.getElementAtIndex(x).getType() === (currentPlayer ? "black" : "white");
    }

    function freeOrChain(x) {
        var pointType = grid.getElementAtIndex(x).getType();
        return pointType === "" || pointType === (currentPlayer ? "white" : "black");
    }

    point.put(currentPlayer, animation);

    if (neighbors.length === 0) {
        return true;
    }

    var somethingToRemove = false;
    var movementAutorized = true;

    /*
     * Check for pieces to remove.
     */
    neighbors.filter(isOponnent).forEach(function(neighbor) {

        var piecesToRemove = getChainToRemove(neighbor, grid, isOponnent);
        if (piecesToRemove.length !== 0) {
            somethingToRemove = true;
        }
        piecesToRemove.forEach(function(x) {
            grid.getElementAtIndex(x).remove(animation);
        })
    });

    /*
     * Check for suicide.
     */
    if (!somethingToRemove) {
        var suicides = getChainToRemove(index, grid, isPlayer);
        if (suicides.length !== 0) {
            if (allowSuicide) {
                suicides.forEach(function(x) {
                    grid.getElementAtIndex(x).remove(animation);
                });
            } else {
                point.remove(false);
                movementAutorized = false;
            }
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
    for (var i = 0; i < grid.columns * grid.rows; i++) {
        grid.getElementAtIndex(i).mark = false;
    }

    return movementAutorized;

}
