#!/bin/bash


TYPE=$1

if [ "$TYPE" == "" ]; then
    TYPE="stretch"
fi


PACKAGE_NAME=qt-openhd-pi-${TYPE}

VERSION=$(git describe)

fpm -s dir -t deb -n ${PACKAGE_NAME} -v ${VERSION//v} -C debian \
  -p ../${PACKAGE_NAME}_VERSION_ARCH.deb \
  -d "libegl1-mesa >= 13.0.6" \
  -d "libgles2-mesa >= 13.0.6" \
  -d "libgbm1 >= 13.0.6" \
  -d "libfontconfig1 >= 2.11.0" \
  -d "libdbus-1-3 >= 1.10.28" \
  -d "libfreetype6 >= 2.6.3" \
  -d "libicu57 >= 57.1" \
  -d "libinput-bin >= 1.6.3" \
  -d "libxkbcommon0 >= 0.7.1" \
  -d "libsqlite3-0 >= 3.16.2" \
  -d "libpng16-16 >= 1.6.28" \
  -d "libjpeg8 > 0" \
  -d "libglib2.0-0 >= 2.50.3" \
  -d "libasound2 >= 1.1.3" \
  -d "libxcb-xfixes0 >= 1.12" \
  -d "libdrm2 >= 2.4.74" \
  -d "pulseaudio >= 10.0" \
  -d "libpulse0 >= 10.0" \
  -d "libspeechd-dev >= 0.8.6" \
  -d "flite1-dev >= 2.0.0" \
  -d "flite >= 2.0.0" \
  -d "speech-dispatcher-flite >= 0.8.6" \
  -d "libdouble-conversion >= 2.0" \
  -d "libudev >= 0" \
  -d "libinput >= 0" \
  -d "libts >= 0" \
  -d "mtdev-tools >= 0" || exit 1

