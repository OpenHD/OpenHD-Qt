#!/bin/bash

PLATFORM=$1
DISTRO=$2

if [ "$PLATFORM" == "" ]; then
    PLATFORM="pi"
    DISTRO="stretch"
fi

if [[ "${PLATFORM}" == "pi" ]]; then
    OS="raspbian"
    ARCH="arm"
    PACKAGE_ARCH="armhf"
fi


PACKAGE_NAME=openhd-qt

TMPDIR=/tmp/${PACKAGE_NAME}-installdir

VERSION=$(git describe)

rm ${PACKAGE_NAME}_${VERSION//v}_${PACKAGE_ARCH}.deb > /dev/null 2>&1

fpm -a ${PACKAGE_ARCH} -s dir -t deb -n ${PACKAGE_NAME} -v ${VERSION//v} -C ${TMPDIR} \
  -p ${PACKAGE_NAME}_VERSION_ARCH.deb \
  -d "libegl1-mesa >= 13.0.6" \
  -d "libgles2-mesa >= 13.0.6" \
  -d "libgbm1 >= 13.0.6" \
  -d "libfontconfig1 >= 2.11.0" \
  -d "libdbus-1-3 >= 1.10.28" \
  -d "libfreetype6 >= 2.6.3" \
  -d "libicu-dev >= 57.1" \
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
  -d "libdouble-conversion1 >= 2.0" \
  -d "libudev1 >= 0" \
  -d "libinput10 >= 1.6.3" \
  -d "libts-dev >= 1.0" \
  -d "mtdev-tools >= 0" || exit 1

