#!/bin/bash

QT_MAJOR_VERSION=5.15
QT_MINOR_VERSION=0

TYPE=$1

if [ "$TYPE" == "" ]; then
    echo "Missing build type: pi-stretch, pi-buster, jetson-nano"
    exit 1
fi

if [ "$TYPE" == "pi-stretch" ]; then
    PLATFORM="linux-rpi-g++"
    SSL_ARGS="-no-openssl"
elif [ "$TYPE" == "pi-bullseye" ]; then
    PLATFORM="linux-rpi4-v3d-g++"
    SSL_ARGS="-openssl"
elif [ "$TYPE" == "jetson-nano" ]; then
    PLATFORM="linux-jetson-nano-g++"
    SSL_ARGS="-openssl"
fi

PACKAGE_NAME=openhd-qt-${TYPE}

TMPDIR=/tmp/${PACKAGE_NAME}-installdir

mkdir -p ${TMPDIR}

rm -r ${TMPDIR}/*


if [ "$TYPE" == "pi-stretch" ]; then
    # fix broadcom opengl  library names without breaking anything else
    ln -sf /opt/vc/lib/libbrcmEGL.so /opt/vc/lib/libEGL.so
    ln -sf /opt/vc/lib/libEGL.so /opt/vc/lib/libEGL.so.1
    ln -sf /opt/vc/lib/libbrcmGLESv2.so /opt/vc/lib/libGLESv2.so
    ln -sf /opt/vc/lib/libbrcmGLESv2.so /opt/vc/lib/libGLESv2.so.2
    ln -sf /opt/vc/lib/libbrcmOpenVG.so /opt/vc/lib/libOpenVG.so
    ln -sf /opt/vc/lib/libbrcmWFC.so /opt/vc/lib/libWFC.so

    ln -sf /opt/vc/lib/pkgconfig/brcmegl.pc    /opt/vc/lib/pkgconfig/egl.pc
    ln -sf /opt/vc/lib/pkgconfig/brcmglesv2.pc /opt/vc/lib/pkgconfig/glesv2.pc
    ln -sf /opt/vc/lib/pkgconfig/brcmvg.pc     /opt/vc/lib/pkgconfig/vg.pc
fi

if [ ! -f qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}.tar.xz ]; then
        echo "Download Qt ${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}"
        wget -q --show-progress --progress=bar:force:noscroll http://download.qt.io/official_releases/qt/${QT_MAJOR_VERSION}/${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}/single/qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}.tar.xz
fi

echo "Building Qt for ${TYPE} (${PLATFORM})"

# blow away the old directory to guarantee clean source state
if [ -d qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION} ]; then
        rm -rf qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}
fi

tar xf qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}.tar.xz || exit 1

if [ ! -f qt-raspberrypi-configuration ]; then
    git clone https://github.com/OpenHD/qt-raspberrypi-configuration
fi

apt -y install wget xz-utils 

pushd qt-raspberrypi-configuration
make install DESTDIR=../qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}
popd


apt-get update

apt -y install build-essential \
flite \
flite1-dev \
libasound2-dev \
libdbus-1-dev \
libdouble-conversion-dev \
libdrm-dev \
libegl1-mesa-dev \
libfontconfig1-dev \
libfreetype6-dev \
libgbm-dev \
libgles2-mesa-dev \
libglib2.0-dev \
libicu-dev \
libinput-dev \
libjpeg-dev \
libnss3-dev \
libpng-dev \
libpulse-dev \
libspeechd-dev  \
libsqlite3-dev \
libssl-dev \
libts-dev \
libudev-dev \
mtdev-tools \
pulseaudio \
speech-dispatcher-flite \
libxcb-xfixes0-dev \
libxkbcommon-dev


rm -rf build

mkdir -p build

pushd build

../qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}/configure -v -platform ${PLATFORM} \
-v \
-opengl es2 -eglfs \
-no-gtk \
-opensource -confirm-license -release \
-reduce-exports \
-force-pkg-config \
-nomake examples -no-compile-examples \
-skip qtwayland \
-skip qtxmlpatterns \
-skip qtsensors \
-skip qtpurchasing \
-skip qtnetworkauth \
-no-feature-cups \
-no-feature-testlib \
-no-feature-dbus \
-no-feature-vnc \
-no-compile-examples \
-no-feature-geoservices_mapboxgl \
-no-feature-xlib \
-no-xcb \
-qt-pcre \
-no-pch ${SSL_ARGS} \
-evdev \
-system-freetype \
-fontconfig \
-glib \
-prefix /opt/Qt${QT_MAJOR_VERSION}.${QT_MINOR_VERSION} \
-qpa eglfs || exit 1

make -j1 || exit 1

INSTALL_ROOT=${TMPDIR} make install || exit 1

popd
