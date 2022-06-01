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
TARGET = harbour-multimodal

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-multimodal.qml \
    qml/pages/*.qml \
    src/dbahn_client/*.py \
    src/ldbws_client/*.py \
    src/tfgm_client/*.py \
    src/tfgm_xml_client/*.py \
    src/tfl_client/*.py \
    src/trest_client/*.py \
    src/*.py \
    route.db \
    img/* \
    rpm/harbour-multimodal.spec \
    translations/*.ts \
    harbour-multimodal.desktop


# Python Data
src.files = src/*
src.path = /usr/share/$${TARGET}/src

# image files
img.files = img/*
img.path = /usr/share/$${TARGET}/img

db.files = route.db
db.path = /usr/share/$${TARGET}/

INSTALLS += src img db

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-multimodal-de.ts
