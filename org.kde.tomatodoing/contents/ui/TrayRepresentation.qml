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
import QtQuick 2.5
import QtQuick.Layouts 1.2
import org.kde.plasma.plasmoid 2.0
import "../code/enums.js" as Enums
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents


Item {
    id: trayRepresentation

    property bool showTimer: true
    property string timeString: Qt.formatTime(new Date(0,0,0,0,0, root.timer.seconds), "mm:ss")

    PlasmaCore.Svg {
        id: svgIconsFile
        imagePath: plasmoid.file("images", "trayIcons.svg") // "../images/tomatoid.svgz" // "../images/tomatoes-" + sourceIcon + ".svg"
    }

    PlasmaCore.SvgItem {
        id: svgIconItem
        anchors.fill: parent
        svg: svgIconsFile
        elementId: "tomatoid-idle"
    }

//    Image {           //Con SVG no escala
//        id: longa
//        source: "../images/tomatoes-" + sourceIcon + ".svg"
//        anchors.fill: parent
//    }

    Item {
        id: timerContainer
        anchors.centerIn: parent
        visible: false
        property real size: Math.min(parent.width, parent.height)
        height: size
        width: size

        Rectangle {
            id: labelRect
            // should be 40 when size is 90
            width: Math.max(parent.size*4/9, 35)
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

    states: [
        State {
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
