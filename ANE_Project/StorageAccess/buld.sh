#!/usr/bin/bash
set -e
FLEXAIR_HOME=$AIR_HOME
rm -rf bin
mkdir -p bin

echo "Compile java using javac..."
javac --release 8 -d bin/ \
    -classpath "$FLEXAIR_HOME/lib/android/FlashRuntimeExtensions.jar:$HOME/Android/Sdk/platforms/android-34/android.jar:$FLEXAIR_HOME/lib/android/lib/runtimeClasses.jar:libs/documentfile.jar" \
    java/src/com/miokotech/storageaccess/*.java
jar cf bin/StorageAccess.jar bin/com/

echo "Compile source to swc..."
$FLEXAIR_HOME/bin/compc \
    -source-path as_wrapper \
    -include-classes com.miokotech.storageaccess.StorageAccess \
    -output bin/StorageAccess.swc -swf-version=46

echo "Unzip library.swf dari SWC"
unzip -o bin/StorageAccess.swc library.swf
mv library.swf bin/

echo "Making ane..."
adt -package -target ane bin/StorageAccess.ane extension.xml \
    -swc bin/StorageAccess.swc \
    -platform Android-ARM -C bin StorageAccess.jar library.swf

echo "Copying ane to extension dir..."
cp bin/StorageAccess.ane ../../extension/
