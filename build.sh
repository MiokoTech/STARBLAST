#!/bin/bash
set -e
FLEXAIR_HOME=$AIR_HOME

# Kompile sumber kode menjadi SWF
mkdir -p release_app
xvfb-run -a $FLEXAIR_HOME/bin/amxmlc \
  -source-path android_app/src libs/ android_app/global/ \
  -swf-version=46 \
  -library-path+=:swc/ \
  -external-library-path+=:extension/StorageAccess.ane \
  -external-library-path+=:extension/GameAudio.ane \
  -output release_app/launchWUFAN.swf \
  android_app/src/launchWUFAN.as

# Kompile aplikasi
xvfb-run -a $FLEXAIR_HOME/bin/adt \
   -package -target apk-captive-runtime \
   -storetype pkcs12 \
   -keystore keysign/starblast_bvn.p12 -storepass ookami \
    release_app/starblast_v3.apk \
    android_app/src/launchWUFAN-app.xml \
    -extdir extension/ \
    -C release_app launchWUFAN.swf \
    -C . common/icon/ \
    -C . assets/
