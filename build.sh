#!/bin/bash

QT_MAJOR_VERSION=5.15
QT_MINOR_VERSION=4

TYPE=$1

if [ "$TYPE" == "" ]; then
    echo "Missing build type: pi-bullseye, jetson-nano-bionic"
    exit 1
fi


if [ "$TYPE" == "pi-bullseye" ]; then
    QTPLATFORM="eglfs"
    PROCESSES="4"
    PLATFORM="linux-rpi-vc4-g++"
    SSL_ARGS="-openssl"
elif [ "$TYPE" == "jetson-nano-bionic" ]; then
    QTPLATFORM="eglfs"
    PROCESSES="4"
    PLATFORM="linux-jetson-nano-g++"
    SSL_ARGS="-openssl"
elif [ "$TYPE" == "x86-focal" ]; then
    QTPLATFORM="xcb"
    PROCESSES="12"
    PLATFORM="linux-g++"
    SSL_ARGS="-openssl"
elif [ "$TYPE" == "x86-jammy" ]; then
    QTPLATFORM="xcb"
    PROCESSES="12"
    PLATFORM="linux-g++"
    SSL_ARGS="-openssl"

fi

PACKAGE_NAME=openhd-qt-${TYPE}

TMPDIR=/tmp/${PACKAGE_NAME}

mkdir -p ${TMPDIR}

sudo rm -r ${TMPDIR}/*
rm -rf qt-*

if [ ! -f qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}.tar.xz ]; then
        echo "Download Qt ${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}"
        wget -q --show-progress --progress=bar:force:noscroll https://download.qt.io/archive/qt/5.15/5.15.4/single/qt-everywhere-opensource-src-5.15.4.tar.xz
fi

echo "Building Qt for ${TYPE} (${PLATFORM})"

# blow away the old directory to guarantee clean source state
if [ -d qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION} ]; then
        rm -rf qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}
fi

tar xf qt-everywhere-opensource-src-5.15.4.tar.xz || exit 1
            RENDER="opengl desktop"
if [ "$TYPE" == "pi-bullseye" ]; then

        if [ ! -f qt-raspberrypi-configuration ]; then
            git clone https://github.com/OpenHD/qt-raspberrypi-configuration.git
            RENDER="opengl es2"
        fi
elif [ "$TYPE" == "jetson-nano" ]; then
         if [ ! -f qt-raspberrypi-configuration ]; then
            git clone https://github.com/OpenHD/qt-raspberrypi-configuration.git
            RENDER="opengl es2"
        fi
fi
pushd qt-raspberrypi-configuration
make install DESTDIR=../qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}
popd

sudo rm -rf build

mkdir -p build

pushd build

../qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}/configure -v -platform ${PLATFORM} \
-v \
-${RENDER} \
-opensource -confirm-license -release \
-reduce-exports \
-force-pkg-config \
-nomake examples -no-compile-examples -nomake tests \
-skip qtwebengine \
-skip qtxmlpatterns \
-skip qtsensors \
-skip qtpurchasing \
-skip qtnetworkauth \
-skip qt3d \
-no-feature-cups \
-no-feature-testlib \
-no-feature-dbus \
-no-feature-vnc \
-no-compile-examples \
-no-feature-geoservices_mapboxgl \
-qt-pcre \
-no-pch \
-ssl \
-kms \
-xcb \
-xcb-xlib \
-gtk \
-gbm \
-evdev \
-eglfs \
-system-freetype \
-fontconfig \
-glib \
-prefix /opt/Qt${QT_MAJOR_VERSION}.${QT_MINOR_VERSION} \
-no-feature-eglfs_brcm \
-qpa ${QTPLATFORM} || exit 1

ls -a
sed -i '309 i #elif defined(__ARM_ARCH_8A__)' ../qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}/qtscript/src/3rdparty/javascriptcore/JavaScriptCore/wtf/Platform.h
sed -i '310 i #define WTF_CPU_ARM_TRADITIONAL 1' ../qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}/qtscript/src/3rdparty/javascriptcore/JavaScriptCore/wtf/Platform.h

make -j${PROCESSES}

echo "Build Complete"
echo "Build Complete"
echo "Build Complete"
echo "Build Complete"
echo "Build Complete"
echo "Build Complete"
echo "Build Complete"
echo "Build Complete"
echo "Build Complete"
echo "Build Complete"

sudo INSTALL_ROOT=${TMPDIR} make install

echo "Install Complete"
echo "Install Complete"
echo "Install Complete"
echo "Install Complete"
echo "Install Complete"
echo "Install Complete"

popd
