
QT_MAJOR_VERSION=5.15
QT_MINOR_VERSION=0

TYPE=$1

if [ "$TYPE" == "" ]; then
    TYPE="stretch"
fi

if [ "$TYPE" == "stretch" ]; then
    PLATFORM="linux-rpi-g++"
elif [ "$TYPE" == "buster" ]; then
    PLATFORM="linux-rpi-vc4-g++"
fi

PACKAGE_NAME=openhd-qt

TMPDIR=/tmp/${PACKAGE_NAME}-installdir

mkdir -p ${TMPDIR}

rm -r ${TMPDIR}/*


if [ "$TYPE" == "stretch" ]; then
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
        wget http://download.qt.io/official_releases/qt/${QT_MAJOR_VERSION}/${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}/single/qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}.tar.xz
fi

echo "Building Qt for ${TYPE} (${PLATFORM})"

# blow away the old directory to guarantee clean source state
if [ -d qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION} ]; then
        rm -rf qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}
fi

tar xvf qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}.tar.xz

rm -r qt-raspberrypi-configuration
git clone https://github.com/oniongarlic/qt-raspberrypi-configuration.git

cd qt-raspberrypi-configuration && make install DESTDIR=../qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}
cd ..

apt-get update

apt-get install build-essential \
libfontconfig1-dev \
libdbus-1-dev \
libfreetype6-dev \
libicu-dev \
libinput-dev \
libxkbcommon-dev \
libsqlite3-dev \
libssl-dev \
libpng-dev \
libjpeg8-dev \
libglib2.0-dev \
libasound2-dev \
libxcb-xfixes0-dev \
libdrm-dev \
pulseaudio libpulse-dev \
libspeechd-dev flite1-dev flite speech-dispatcher-flite \
libdouble-conversion-dev \
libudev-dev \
libinput-dev \
libts-dev \
mtdev-tools


rm -rf build

mkdir -p build

cd build

../qt-everywhere-src-${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}/configure -platform ${PLATFORM} \
-v \
-opengl es2 -eglfs \
-no-gtk \
-opensource -confirm-license -release \
-reduce-exports \
-force-pkg-config \
-nomake examples -no-compile-examples \
-skip qtdatavis3d \
-skip qtwayland \
-skip qtwebengine \
-skip qtconnectivity \
-skip qtxmlpatterns \
-skip qtsensors \
-skip qtpurchasing \
-skip qtnetworkauth \
-skip qtwebchannel \
-skip qtwebsockets \
-skip qtwebview \
-no-feature-cups \
-no-feature-testlib \
-no-feature-dbus \
-no-feature-vnc \
-no-compile-examples \
-no-feature-geoservices_mapboxgl \
-no-feature-xlib \
-no-xcb \
-qt-pcre \
-no-pch \
-ssl \
-evdev \
-system-freetype \
-fontconfig \
-glib \
-prefix /usr/local \
-qpa eglfs

make -j5

make install DESTDIR=${TMPDIR} || exit 1

cd ..
