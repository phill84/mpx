#!/usr/bin/env bash
set -e

MPV_VER=0.14.0
SCRIPT_DIR=$(cd $(dirname $0); pwd)

cd $SCRIPT_DIR/..
# download mpv tarball
[[ -f v$MPV_VER.tar.gz ]] && rm -f v$MPV_VER.tar.gz
wget https://github.com/mpv-player/mpv/archive/v$MPV_VER.tar.gz
[[ -d mpv-$MPV_VER ]] && rm -rf mpv-$MPV_VER
tar zxf v$MPV_VER.tar.gz

# (re)install mpv deps
brew install --HEAD ffmpeg --without-fontconfig --without-libass
brew install lcms2 \
			libass \
			libbluray \
			libdvdread \
			libdvdnav \
			enca \
			uchardet \
			libjpeg \
			fontconfig

cd mpv-$MPV_VER
# compile libmpv
export PKG_CONFIG_PATH=/usr/local/opt/libass-git/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/lib
python bootstrap.py
./waf configure --disable-cplayer \
				--enable-libmpv-shared \
				--enable-static-build \
				--disable-lua
./waf clean build

# copy libmpv.dylib
LIBMPV=$(basename $(ls build/libmpv.*.*.*.dylib))
[[ -d $SCRIPT_DIR/lib ]] && rm -rf $SCRIPT_DIR/lib
mkdir $SCRIPT_DIR/lib
cp -L build/$LIBMPV $SCRIPT_DIR/lib/

python $SCRIPT_DIR/patch_libmpv_deps.py $SCRIPT_DIR/lib/$LIBMPV
