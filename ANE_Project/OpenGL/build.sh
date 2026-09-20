#!/usr/bin/bash
set -e
FLEXAIR_HOME=${AIR_HOME:-"/data/data/com.termux/files/home/sdks/air"}
ADT_CMD=$(which adt 2>/dev/null || echo "$FLEXAIR_HOME/bin/adt")
COMPC_CMD=$(which compc 2>/dev/null || echo "$FLEXAIR_HOME/bin/compc")

rm -rf bin
mkdir -p bin

echo "Compile Java using javac..."
javac --release 8 -d bin/ \
    -classpath "$FLEXAIR_HOME/lib/android/FlashRuntimeExtensions.jar:$HOME/Android/Sdk/platforms/android-34/android.jar:$FLEXAIR_HOME/lib/android/lib/runtimeClasses.jar" \
    java/src/com/miokotech/opengl/*.java

jar cf bin/GameOpenGL.jar -C bin com

echo "Compile ActionScript 3 wrapper to SWC..."
$COMPC_CMD \
    -source-path as_wrapper \
    -include-classes com.miokotech.opengl.GameOpenGL \
    -output bin/GameOpenGL.swc -swf-version=46

echo "Extract library.swf from SWC..."
unzip -o bin/GameOpenGL.swc library.swf
mv library.swf bin/

echo "Packaging ANE with ADT..."
$ADT_CMD -package -target ane bin/GameOpenGL.ane extension.xml \
    -swc bin/GameOpenGL.swc \
    -platform Android-ARM -C bin GameOpenGL.jar library.swf

echo "Copying ANE to project extension/ directory..."
mkdir -p ../../extension/
cp bin/GameOpenGL.ane ../../extension/

echo "Build complete: bin/GameOpenGL.ane -> ../../extension/GameOpenGL.ane"
