#!/usr/bin/env python
# -*- coding: utf-8 -*-

import random
from transformations import *


class Game(object):
    """" A game loaded from a sgf data source.
    """

    def __init__(self, cursor):
        """ Create a new Game on the current cursor position.
        :cursor: The cursor opened at the game.
        """

        node = cursor.currentNode()

        # display problem name
        name = ''
        if 'GN' in node:
            name = node['GN'][0][:15]
        self.name = name

        while not ('AG' in node or 'AW' in node \
                   or 'B' in node or 'W' in node):
            node = cursor.next()

        self.min_x, self.min_y = 19, 19
        self.max_x, self.max_y = 0, 0

        # Get the board size from the whole possibles positions and create the
        # game tree
        self.tree = Game.create_tree(cursor, self.extend_board_size, [])

        x_space = 2
        y_space = 2

        if self.min_y > y_space:
            self.min_y -= y_space

        if self.min_x > x_space:
            self.min_x -= x_space

        if self.max_y < 19 - y_space:
            self.max_y += y_space

        if self.max_x < 19 - x_space:
            self.max_x += x_space

        self.side = {
            "TOP": self.min_y != 0,
            "LEFT": self.min_x != 0,
            "RIGHT": self.max_x != 19,
            "BOTTOM": self.max_y != 19,
        }


    def extend_board_size(self, pos):
        """ Extend the board size to include the position given.
        """
        x, y = Game.conv_coord(pos)
        self.min_x = min(x, self.min_x)
        self.max_x = max(x, self.max_x)
        self.min_y = min(y, self.min_y)
        self.max_y = max(y, self.max_y)
        return (x, y)

    @staticmethod
    def create_tree(cursor, fun, acc=None):
        """ Walk over the whole node in the game and call fun for each of them.
        :cursor:    The cursor in the sgf parser.
        :fun:       Function called for each position read
        """

        if acc is None:
            acc = []

        node = cursor.currentNode().copy()
        for key in ['AB', 'AW', 'B', 'W']:
            if key in node:
                node[key] = [fun(pos) for pos in node[key]]

        acc.append(node)
        childs = cursor.noChildren()

        if childs == 1:
            # When there is only one child, we just add it to the current path
            cursor.next()
            Game.create_tree(cursor, fun, acc)
            cursor.previous()
        elif childs > 1:
            # Create a new list containing each subtree
            sub_nodes = []
            for i in range(childs):
                cursor.next(i)
                sub_nodes.append(Game.create_tree(cursor, fun))
                cursor.previous()
            acc.append(sub_nodes)
        return acc

    def get_size(self):
        #return self.max_x, self.max_y
        x_size = self.max_x - self.min_x
        y_size = self.max_y - self.min_y
        return min(19, x_size + 1), min(19, y_size + 1)

    @staticmethod
    def conv_coord(x):
        """ This takes coordinates in SGF style (aa - qq) and returns the
        corresponding integer coordinates (between 1 and 19). """

        print(x)

        return tuple([ord(c) - 96 for c in x])

    def parse_tree(self, fun, elements=None):
        """" Parse the current tree, and apply fun to each element.
        """

        if elements is None:
            elements = self.tree

        for elem in elements:
            if isinstance(elem, dict):
                for key in ['AB', 'AW', 'B', 'W']:
                    if key in elem:
                        elem[key] = [fun(pos) for pos in elem[key]]
#                for type, values in elem.items():
#                    elem[type] = [fun(coord) for coord in values]
            else:
                for l in elem:
                    self.parse_tree(fun, l)

    def normalize(self):
        """ Create a normalized board, translated on lower coord.
        """

        for transformation in [Translation(self), Rotation(self), Translation(self), Symmetry(self)]:
            if not transformation.is_valid():
                continue

            self.parse_tree(transformation.apply_points)
            self.min_x, self.min_y, self.max_x, self.max_y = transformation.get_new_size()
            self.side = transformation.get_new_side()
