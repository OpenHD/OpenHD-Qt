#!/usr/bin/env bash

touch /etc/ld.so.conf.d/qt.conf
echo "/opt/Qt5.15.7/lib/" >/etc/ld.so.conf.d/qt.conf
sudo ldconfig
export PATH="$PATH:/opt/Qt5.15.7/bin/"
cd /usr/bin
rm -f qmake
sudo ln -s /opt/Qt5.15.7/bin/qmake qmake