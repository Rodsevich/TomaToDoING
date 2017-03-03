/*
 * Copyright 2015  Martin Kotelnik <clearmartin@seznam.cz>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.7
import QtQuick.Layouts 1.2
import org.kde.plasma.plasmoid 2.0
import "../code/enums.js" as Enums
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "Components"

Item {
    id: trayRepresentation

    property bool showTimer: true
    property string timeString: Qt.formatTime(new Date(0,0,0,0,0, root.timer.seconds), "mm:ss")

    property int arrX1: 10
    property int arrX2 //: parent.width - arr2.width - 30

    Layout.minimumWidth: 200
    Layout.maximumWidth: 400

//    Image {           //Con SVG no escala
//        id: longa
//        source: "../images/tomatoes-" + sourceIcon + ".svg"
//        anchors.fill: parent
//    }

    PlasmaCore.Svg {
        id: svgIconsFile
        imagePath: plasmoid.file("images", "trayIcons.svg") // "../images/tomatoid.svgz" // "../images/tomatoes-" + sourceIcon + ".svg"
    }

    PlasmaCore.SvgItem {
        id: svgIconItem
        height: parent.height
        width: parent.height
        svg: svgIconsFile
        elementId: "tomatoid-idle"
    }

    Rectangle {
        id: displayBackground
        width: parent.width - svgIconItem.width
        color: theme.viewBackgroundColor
        height: parent.height * .8
        anchors.right: parent.right
        anchors.horizontalCenter: undefined
        anchors.verticalCenter: svgIconItem.verticalCenter
        radius: 20

        SequentialAnimation on color{
            id: backgroundColorFlash
            loops: Animation.Infinite
            running: false
            ColorAnimation { duration: 100; to: theme.highlightColor }
            ColorAnimation { duration: 100; to: theme.complementaryBackgroundColor}
        }
    }

    Text{
        id: displayText
        text: root.currentTodo.summary
        color: theme.complementaryTextColor
        anchors.centerIn: displayBackground
    }

    Arrow{
        id: arr1
        rotation: 180
        width: parent.width / 10
        height: parent.height - 10
        anchors.verticalCenter: parent.verticalCenter
        fillColor: theme.viewFocusColor
        strokeColor: theme.viewTextColor
        visible: false
        x: arrX1
    }

    Arrow{
        id: arr2
        width: parent.width / 10
        height: parent.height - 10
        anchors.verticalCenter: parent.verticalCenter
        fillColor: theme.viewFocusColor
        strokeColor: theme.viewTextColor
        visible: false
        x: arrX2
    }

    Item {
        id: timerContainer
        anchors.centerIn: svgIconItem
        visible: false
        property real size: Math.min(parent.width, parent.height)
        height: size
        width: size

        Rectangle {
            id: labelRect
            // should be 40 when size is 90
            width: Math.max(parent.size*4/9, 35)// ¡4/9! soy complicado, eh... O.o
            height: width/2
            anchors.centerIn: parent
            color: theme.backgroundColor
            border.color: "grey"
            border.width: 2
            radius: 4
            opacity: mouseArea.containsMouse ? 0.8 : 0.6

            Behavior on opacity { NumberAnimation { duration: 300 } }
        }

        Text {
            id: overlayText
            text: timeString
            color: theme.textColor
            font.pixelSize: Math.max(timerContainer.size/8, 11)
            anchors.centerIn: labelRect
            opacity: labelRect.opacity > 0 ? 1 : 0
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            plasmoid.expanded = !plasmoid.expanded;
        }
    }

    Component.onCompleted: {
        arrX2 = parent.width - parent.width/10 - 30;
        arr2.x = arrX2;
        arrAnim2.restart();
    }

    SequentialAnimation {
        id: arrAnim1
        loops: Animation.Infinite
        running: false

        NumberAnimation {
            target: arr1
            property: "x"
            duration: 200
            to: arrX1 + 20
        }

        NumberAnimation {
            target: arr1
            property: "x"
            duration: 300
            to: arrX1
        }
    }

    SequentialAnimation {
        id: arrAnim2
        loops: Animation.Infinite
        running: false

        NumberAnimation {
            target: arr2
            property: "x"
            duration: 200
            to: arrX2
        }

        NumberAnimation {
            target: arr2
            property: "x"
            duration: 300
            to: arrX2 + 20
        }
    }

    states: [
        State {
            name: "idle"
            PropertyChanges {
                target: svgIconItem
                elementId: "tomatoid-idle"
            }

            PropertyChanges {
                target: timerContainer
                visible: false
            }
        },
        State {
            name: "idleWhenShouldBeWorking"
            when: !root.inPomodoro && !root.inPause && !root.inBreak && root.autostarterUI.inEventRunning

            PropertyChanges{
                target: svgIconItem
                visible: false
            }

            PropertyChanges{
                target: displayBackground
                anchors.right: undefined
                anchors.horizontalCenter: trayRepresentation.horizontalCenter
                width: trayRepresentation.width - (arr1.width + 20 + arrX1) * 2
            }

            PropertyChanges{
                target: displayText
                text: root.autostarterUI.forthcomingEvent.summary
                font.bold: true
            }

            PropertyChanges{
                target: arrAnim1
                running: true
            }

            PropertyChanges{
                target: arrAnim2
                running: true
            }

            PropertyChanges{
                target: backgroundColorFlash
                running: true
            }

            PropertyChanges{
                target: arr1
                visible: true
            }

            PropertyChanges{
                target: arr2
                visible: true
            }

            onCompleted: root.sirenSound.play()

        },
        State {
            name: "working"
            when: root.inPomodoro

            PropertyChanges {
                target: svgIconItem
                elementId: "tomatoid-running"
            }

            PropertyChanges {
                target: timerContainer
                visible: true
            }

            PropertyChanges {
                target: displayBackground
                color: theme.complementaryFocusColor
            }

            onCompleted: root.sirenSound.stop()
        },
        State {
            name: "paused"
            when: root.inPause

            PropertyChanges {
                target: svgIconItem
                elementId: "tomatoid-paused"
                visible: true
            }

            PropertyChanges {
                target: timerContainer
                visible: true
            }
        },
        State {
            name: "break"
            when: root.inBreak

            PropertyChanges {
                target: svgIconItem
                elementId: "tomatoid-break"
                visible: true
            }

            PropertyChanges {
                target: timerContainer
                visible: true
            }

        }
    ]
}
