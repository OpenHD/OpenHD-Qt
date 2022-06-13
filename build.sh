#!/bin/bash

QT_MAJOR_VERSION=5.15
QT_MINOR_VERSION=4

TYPE=$1

if [ "$TYPE" == "" ]; then
    echo "Missing build type: pi-bullseye, jetson-nano"
    exit 1
fi


if [ "$TYPE" == "pi-bullseye" ]; then
    PLATFORM="linux-rpi4-v3d-g++"
    SSL_ARGS="-openssl"
elif [ "$TYPE" == "jetson-nano" ]; then
    PLATFORM="linux-jetson-nano-g++"
    SSL_ARGS="-openssl"
fi

PACKAGE_NAME=openhd-qt-${TYPE}

TMPDIR=/tmp/${PACKAGE_NAME}-installdir

mkdir -p ${TMPDIR}

sudo rm -r ${TMPDIR}/*


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

if [ ! -f qt-raspberrypi-configuration ]; then
    git clone https://github.com/oniongarlic/qt-raspberrypi-configuration.git
fi


pushd qt-raspberrypi-configuration
make install DESTDIR=../qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}
popd

sudo rm -rf build

mkdir -p build

pushd build

../qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}/configure -v -platform linux-rpi4-v3d-g++ \
-v \
-v \
-opengl es2 -eglfs \
-no-gtk \
-opensource -confirm-license -release \
-reduce-exports \
-force-pkg-config \
-nomake examples -no-compile-examples -nomake tests \
-skip qtwebengine \
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
-no-feature-qt3d-animation \
-no-feature-qt3d-extras \
-no-feature-qt3d-input \
-no-feature-qt3d-logic \
-no-feature-qt3d-opengl-renderer \
-no-feature-qt3d-render \
-no-feature-qt3d-rhi-renderer \
-no-feature-qt3d-simd-avx2 \
-no-feature-qt3d-simd-sse2 \
-no-feature-qtlocation \
-no-xcb \
-qt-pcre \
-no-pch \
-ssl \
-kms \
-evdev \
-system-freetype \
-fontconfig \
-glib \
-prefix /opt/Qt${QT_MAJOR_VERSION}.${QT_MINOR_VERSION} \
-no-feature-eglfs_brcm \
-qpa eglfs || exit 1


sed -i '310 i #elif defined(__ARM_ARCH_8A__)' /qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}/qtscript/src/3rdparty/javascriptcore/JavaScriptCore/wtf/Platform.h
sed -i '311 i #define WTF_CPU_ARM_TRADITIONAL 1' /qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}/qtscript/src/3rdparty/javascriptcore/JavaScriptCore/wtf/Platform.h

 make -j1

cd build

sudo chown -R openhd:openhd /opt/
INSTALL_ROOT=${TMPDIR} make install

popd
