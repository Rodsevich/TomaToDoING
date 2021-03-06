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
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
//import QtQuick.LocalStorage 2.0 as Sql
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0 as QtExtra
import org.kde.plasma.components 2.0 as PlasmaComponents

//import "../code/localStorage.js" as DB;
import "../code/dialogs.js" as Dialogs
import "../code/logic.js" as Logic
import "../code/enums.js" as Enums

import "Pages"
import "Components"

Item {

    id: fullRepresentation
    width: 400
    height: 550
    focus: true;

//    PlasmaComponents.Label{
//        id: mainLabel
////        text: "altura: " + stack.height + " UI height: " + calEventsUI.implicitHeight + " mainActBtn: " + (mainActionButton.top + 0)
//        text: "mainActBtn: " + mainActionButton.top
//        anchors.bottom: mainActionButton.top
//        anchors.topMargin: 5
//    }

//    CalendarEventUI{
//        id: calEventsUI
//        calendar: root.calendarObject
//        anchors.top: parent.top
//        anchors.left: parent.left
//        anchors.right: parent.right

//        onStartedEvent: stack.currentPage.signalize("eventAutoStart", _event)
//    }

//    PlasmaComponents.PageStack {
//        id: stack
//        //width automaticamente seteado al del parent
////        height: null
//        anchors.top: calEventsUI.bottom
//        //No parece funcar
////        anchors.bottom: mainActionButton.top
////        anchors.bottomMargin: 3
//        z: -99
//        initialPage: root.idlePage
//    }

    Keys.forwardTo: [stack.currentPage]

    PlasmaComponents.ToolButton {
        id: mainActionButton
        width: 60
        height: width
        implicitHeight: height
        implicitWidth: width
        z: 100
        enabled: {
            switch(root.state){
                case Enums.States.WORKING:
                    return root.pauseEnabled;
                default:
                    return true
            }
        }
        visible: root.state !== Enums.States.SUMMARIZING
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        iconSource: {
            switch(root.state){
                case Enums.States.IDLE:
                    return "view-task-add"
                case Enums.States.PAUSE:
                    return "media-playback-start"
                case Enums.States.BREAK:
                    return "media-playback-stop"
                case Enums.States.WORKING:
                    return "media-playback-pause"
                case Enums.States.ALMOST_RINGING:
                case Enums.States.RINGING:
                    return "vcs-locally-modified-unstaged"
                case Enums.States.SUMMARIZING:
                    return false;
            }
        }
        onClicked: root.stack.currentPage.mainActionButtonClickHandler()
//        onClicked: Logic.handleMainActionButtonClick()
    }

    Component.onCompleted: {
        //set root.stack as this fullrepresentation child
        root.autostarterUI.parent = this;
        root.autostarterUI.anchors.top = this.top;
        root.autostarterUI.anchors.left = this.left;
        root.autostarterUI.anchors.right = this.right;

        root.stack.parent = this;
//        root.stack.anchors.fill = fullRepresentation;
        root.stack.anchors.top = root.autostarterUI.bottom;
        root.stack.anchors.left = this.left;
        root.stack.anchors.right = this.right;
        root.stack.anchors.bottom = this.bottom;

        console.log(root.autostarterUI.height + " " + root.autostarterUI.implicitHeight);
        console.log(root.autostarterUI.bottom == root.stack.top);

//        root.stack = stack;
//        root.setFullRepresentationPageStack(stack);
        console.log(root.autostarterUI.calendar.events.lenght);
    }
}
