#!/usr/bin/env bash
set -e

MPV_TAG=v0.10.0
SCRIPT_DIR=$(cd $(dirname $0); pwd)

cd $SCRIPT_DIR/..
# checkout mpv
[[ -d mpv ]] && rm -rf mpv
git clone https://github.com/mpv-player/mpv.git mpv
git -C ./mpv checkout tags/$MPV_TAG

# (re)install mpv deps
brew install --HEAD ffmpeg
brew install libass \
			libbluray \
			libdvdread \
			libdvdnav \
			enca \
			uchardet

cd mpv
# compile libmpv
python bootstrap.py
./waf configure --disable-cplayer \
				--enable-libmpv-shared \
				--enable-static-build \
				--disable-lua \
				--disable-jpeg
./waf clean build

# copy libmpv.dylib
LIBMPV=$(basename $(ls build/libmpv.*.*.*.dylib))
[[ -d $SCRIPT_DIR/lib ]] && rm -rf $SCRIPT_DIR/lib
mkdir $SCRIPT_DIR/lib
cp -L build/$LIBMPV $SCRIPT_DIR/lib/

python $SCRIPT_DIR/patch_libmpv_deps.py $SCRIPT_DIR/lib/$LIBMPV
