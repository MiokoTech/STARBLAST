#!/usr/bin/bash
set -e
FLEXAIR_HOME=$AIR_HOME
rm -rf bin
mkdir -p bin

echo "Compile java using javac..."
javac -d bin/ \
    -classpath "$FLEXAIR_HOME/lib/android/FlashRuntimeExtensions.jar:$HOME/Android/Sdk/platforms/android-34/android.jar:$FLEXAIR_HOME/lib/android/lib/runtimeClasses.jar:libs/documentfile.jar" \
    java/src/com/miokotech/audioroute/*.java
jar cf bin/GameAudio.jar bin/com/

echo "Compile source to swc..."
$FLEXAIR_HOME/bin/compc \
    -source-path as_wrapper \
    -include-classes com.miokotech.audioroute.GameAudio \
    -output bin/GameAudio.swc -swf-version=46

echo "Unzip library.swf dari SWC"
unzip -o bin/GameAudio.swc library.swf
mv library.swf bin/

echo "Making ane..."
adt -package -target ane bin/GameAudio.ane extension.xml \
    -swc bin/GameAudio.swc \
    -platform Android-ARM -C bin GameAudio.jar library.swf

echo "Copying ane to extension dir..."
cp bin/GameAudio.ane ../../extension/
