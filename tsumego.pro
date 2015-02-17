# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = tsumego

CONFIG += sailfishapp

SOURCES += src/tsumego.cpp

OTHER_FILES += qml/tsumego.qml \
    qml/cover/CoverPage.qml \
    qml/content/gfx/*.png \
    rpm/tsumego.changes.in \
    rpm/tsumego.spec \
    rpm/tsumego.yaml \
    translations/*.ts \
    tsumego.desktop \
    qml/pages/Board.qml \
    qml/python/board.py \
    qml/python/sgfparser.py \
    qml/python/goban/sgfparser.py \
    qml/python/goban/game.py \
    qml/python/goban/board.py \
    qml/actions.js \
    qml/pages/Point.qml \
    qml/python/transformations.py \
    qml/python/__init__.py \
    qml/python/game.py \
    qml/pages/Goban.qml \
    qml/content/sgf/hard.sgf \
    qml/content/sgf/easy.sgf \
    qml/javascript/actions.js \
    qml/javascript/goban_util.js \
    qml/javascript/navigator.js \
    qml/content/gfx/ok.svg \
    qml/pages/collections_list.qml \
    qml/python/configuration.py

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/tsumego-de.ts

