#!/usr/bin/env bash

touch /etc/ld.so.conf.d/qt.conf
echo "/opt/Qt5.15.4/lib/" >/etc/ld.so.conf.d/qt.conf
sudo ldconfig
export PATH="$PATH:/opt/Qt5.15.4/bin/"
cd /usr/bin
sudo ln -s /opt/Qt5.15.4/bin/qmake qmake