#!/usr/bin/env bash
set -e

if [[ -z $XCODE_VERSION_ACTUAL ]]; then
	echo 'this script is not supposed to be executed manually' >&2
	exit 1
fi

CODESIGN=$(which codesign)
SRC=$SRCROOT/lib
DEST=$BUILT_PRODUCTS_DIR/$FRAMEWORKS_FOLDER_PATH

if [[ ! -d $DEST ]]; then
	mkdir -p $DEST
fi

if [[ -z $CODE_SIGN_IDENTITY ]]; then
	CODE_SIGN_IDENTITY=-
fi

find $SRC -type f -name '*.dylib' | while read F; do
	DYLIB=$(basename $F)
	echo "copy $F to $DEST/$DYLIB"
	cp $F $DEST/$DYLIB
	$CODESIGN -f -s $CODE_SIGN_IDENTITY $DEST/$DYLIB
done
