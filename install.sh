#!/bin/bash
mkdir build &> /dev/null
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DLIB_INSTALL_DIR=lib -DQML_INSTALL_DIR=lib/qt/qml ..
sudo make install
plasmapkg2 -i ../org.kde.tomatodoing || plasmapkg2 -u ../org.kde.tomatodoing
kbuildsycoca5
