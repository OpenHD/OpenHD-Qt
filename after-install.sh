#!/usr/bin/env bash

rm -f /etc/ld.so.conf.d/qt.conf
touch /etc/ld.so.conf.d/qt.conf
echo "/opt/Qt5.15.4/lib/" >/etc/ld.so.conf.d/qt.conf
ldconfig
export PATH="$PATH:/opt/Qt5.15.4/bin/"
cd /usr/bin
rm -f qmake
ln -s /opt/Qt5.15.4/bin/qmake qmake
echo "QT successfully linked"