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

function getChainToRemove(index, datas, cols, rows, filter) {

    var piecesToCheck = [];
    var piecesToRemove = [];

    /*
     * filter wich keep only free places.
     */
    function freePlaces(x) {
        return datas.itemAt(x).getType() === "";
    }

    var piece = index;
    while (piece !== undefined) {

        /* if the case has already been marked, do not check it again.
         */
        if (!datas.itemAt(piece).mark) {
            datas.itemAt(piece).mark = true;
            piecesToRemove.push(piece);

            var neighbors = getNeighbors(piece, cols, rows);

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

