#!/bin/bash

PLATFORM=$1
DISTRO=$2
BUILD_TYPE=$3

if [ "$PLATFORM" == "" ]; then
    PLATFORM="pi"
    DISTRO="stretch"
fi

if [[ "${PLATFORM}" == "pi" ]]; then
    OS="raspbian"
    ARCH="arm"
    PACKAGE_ARCH="armhf"
fi

if [[ "${PLATFORM}" == "jetson-nano" ]]; then
    OS="ubuntu"
    ARCH="arm64"
    PACKAGE_ARCH="arm64"
fi

if [ "${BUILD_TYPE}" == "docker" ]; then
    cat << EOF > /etc/resolv.conf
options rotate
options timeout:1
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
fi

PACKAGE_NAME=openhd-qt-${PLATFORM}

PKGDIR=/tmp/${PACKAGE_NAME}-installdir

VERSION=$(git describe)

rm ${PACKAGE_NAME}_${VERSION//v}_${PACKAGE_ARCH}.deb > /dev/null 2>&1

apt -y install wget xz-utils 


fpm -a armhf -s dir -t deb -n ${PACKAGE_NAME} -v ${VERSION//v} -C ${PKGDIR} \
  $PLATFORM_CONFIGS \
  -p ${PACKAGE_NAME}_VERSION_ARCH.deb \
  --provides openhd-qt \
  $PLATFORM_PACKAGES \
  -d "flite >= 2.0.0" \
  -d "flite1-dev >= 2.0.0" \
  -d "libasound2 >= 1.1.3" \
  -d "libdbus-1-3 >= 1.10.28" \
  -d "libdouble-conversion3" \
  -d "libdouble-conversion1" \
  -d "libdrm2 >= 2.4.74" \
  -d "libegl1-mesa >= 13.0.6" \
  -d "libfontconfig1 >= 2.11.0" \
  -d "libfreetype6 >= 2.6.3" \
  -d "libgbm1 >= 13.0.6" \
  -d "libgles2-mesa >= 13.0.6" \
  -d "libglib2.0-0 >= 2.50.3" \
  -d "libicu-dev >= 57.1" \
  -d "libicu63" \
  -d "libinput-bin >= 1.6.3" \
  -d "libinput10 >= 1.6.3" \
  -d "libjpeg-dev > 0" \
  -d "libnss3" \
  -d "libpng16-16 >= 1.6.28" \
  -d "libpulse0 >= 10.0" \
  -d "libpulse-mainloop-glib0 >= 10.0" \
  -d "libspeechd-dev >= 0.8.6" \
  -d "libsqlite3-0 >= 3.16.2" \
  -d "libts-dev >= 1.0" \
  -d "libudev1 >= 0" \
  -d "mtdev-tools >= 0" \
  -d "pulseaudio >= 10.0" \
  -d "speech-dispatcher-flite >= 0.8.6" \
  -d "libxcb-xfixes0 >= 1.12" \
  -d "libxkbcommon0 >= 0.7.1" || exit 1


#
# Only push to cloudsmith for tags. If you don't want something to be pushed to the repo, 
# don't create a tag. You can build packages and test them locally without tagging.
#
git describe --exact-match HEAD > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "Pushing package to OpenHD repository"
    cloudsmith push deb openhd/openhd-2-1/${OS}/${DISTRO} ${PACKAGE_NAME}_${VERSION//v}_${PACKAGE_ARCH}.deb
else
    echo "Pushing package to OpenHD Milestone repository"
    cloudsmith push deb openhd/openhd-2-1-alpha/${OS}/${DISTRO} ${PACKAGE_NAME}_${VERSION//v}_${PACKAGE_ARCH}.deb
fi
