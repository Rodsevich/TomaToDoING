#!/bin/bash
mkdir build &> /dev/null
cd build
rm -rf *
#cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DLIB_INSTALL_DIR=lib -DQML_INSTALL_DIR=lib/qt5/qml ..
echo "Running cmake for preparing for compilation... "
if ! cmake ..
then
    echo "ERROR"
    echo "Couldn't load the necessary libraries for compiling? Are there all dependencies installed?"
else
    echo -n "Compiling the plugin... "
    if ! make
    then
        echo "ERROR during compilation. There are errors in the code?"
    else
        echo "COMPILED!"
        echo "Trying to install the plugin (sudo needed)"
        if sudo make install
        then
            echo "installed!"
            #plasmapkg2 -i ../org.kde.tomatodoing || plasmapkg2 -u ../org.kde.tomatodoing
            kbuildsycoca5
        else
            echo "error during installation. Were root privileges provided?"
        fi
    fi
fi
