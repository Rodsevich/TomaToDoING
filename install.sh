#!/bin/bash
mkdir build &> /dev/null
cd build
cmake ..
sudo make install
plasmapkg2 -i ../org.kde.tomatodoing || plasmapkg2 -u ../org.kde.tomatodoing
kbuildsycoca5
