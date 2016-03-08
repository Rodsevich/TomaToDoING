//Highly "inspired" (if not copied) from org.kde.plasma.clipboard

import QtQuick 2.5
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.0
import QtQuick.Controls 1.0 as QtControls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.filecalendarplugin 0.1
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.ListItem{

    id: todoItem

    signal markAsCompleted()
    signal doubleClicked()
    signal subdivideToDo()
    signal deleteToDo()
    signal editToDo()

    property int itemIndex: index
    property CalendarToDo todoComponent: CalendarToDo { }
    property bool hasDescendents: todoComponent.childUid !== ""

    height: texto.implicitHeight
//	width: parent.width
    readonly property real gradientThreshold: (width - toolButtonsLayout.width) / width

    Component.onCompleted: todoComponent = model.modelData

    // this stuff here is used so we can fade out the text behind the tool buttons
    Item {
        id: labelMaskSource
        anchors.fill: parent
        visible: false

        Rectangle {
        anchors.centerIn: parent
        rotation: -90 // you cannot even rotate gradients without QtGraphicalEffects
        width: parent.height
        height: parent.width

        gradient: Gradient {
                    GradientStop { position: 0.0; color: "white" }
                    GradientStop { position: gradientThreshold - 0.25; color: "white"}
                    GradientStop { position: gradientThreshold; color: "transparent"}
                    GradientStop { position: 1; color: "transparent"}
                }
        }
    }
    OpacityMask {
        id: labelMask
        anchors.fill: texto
        cached: true
        maskSource: labelMaskSource
        visible: !!source && todoItem.ListView.isCurrentItem
    }

    QtControls.ProgressBar{
        anchors.fill: parent
        visible: !(todoComponent.completed || todoComponent.childUri !== "")
        value: todoComponent.percentCompleted / 100
        style: ProgressBarStyle{
            background: Rectangle{
                color: todoItem.ListView.isCurrentItem ?
                       theme.viewBackgroundColor
                     : theme.complementaryBackgroundColor
            }
            progress: Rectangle {
                color: todoItem.ListView.isCurrentItem ?
                       theme.visitedLinkColor
                     : Qt.rgba(theme.visitedLinkColor.r,
                       theme.visitedLinkColor.g,
                       theme.visitedLinkColor.b,
                       0.3)
            }
        }
    }

    PlasmaCore.IconItem{
        id: iconItem
        source: "view-task-child-add"
        anchors{
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        width: height
        visible: todoComponent.childUid !== ""
    }

    PlasmaComponents.Label {
        id: texto
        anchors{
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            left: iconItem.visible ? iconItem.right : parent.left
        }
        property string header: {
            if(!todoComponent.priority)
                return "h4"
            if(todoComponent.priority <= 2)
                return "h1"
            if(todoComponent.priority >= 8)
                return "h6"
            if(todoComponent.priority >= 6)
                return "h5"
            return 'h' + (todoComponent.priority - 1)
        }
        text: '<'+header+'>'+ todoComponent.summary +'</'+header+'>'
        textFormat: Text.StyledText
        font.underline: {
            var prioridades = [1,6,8];
            for(var i in prioridades)
                if(todoComponent.priority === prioridades[i])
                return true;
            return false;
        }
        font.strikeout: todoComponent.completed
        color: {
            if(todoComponent.completed)
                return "gray"
            if(todoComponent.overdue)
                return "crimson"
            return theme.textColor
        }
    }

    PlasmaCore.ToolTipArea{
        anchors.fill: parent
        mainText: todoComponent.summary
        subText: todoComponent.description
    }

    MouseArea{
        id: mArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: todoComponent.completed ?
                 Qt.ForbiddenCursor
               : Qt.ArrowCursor
        onContainsMouseChanged: {
            if(!todosView.freezedItem){
                if (containsMouse) {
                    todosView.currentIndex = todoItem.itemIndex
                }
            }
        }
        onClicked: todoItem.clicked()
        onDoubleClicked: todoItem.doubleClicked()
        onPressAndHold: todoItem.pressAndHold()
    }

    Row {
        id: toolButtonsLayout
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: parent.height
        visible: todosView.currentIndex === todoItem.itemIndex
        spacing: 0

        PlasmaComponents.ToolButton {
            iconSource: "document-edit"
            tooltip: i18n("Edit ToDo")
            onClicked: editToDo()
        }
        PlasmaComponents.ToolButton {
            iconSource: "edit-delete"
            visible: !hasDescendents
            tooltip: i18n("Delete ToDo")
            onClicked: deleteToDo()
        }
        PlasmaComponents.ToolButton {
            iconSource: "layer-lower"
            visible: !hasDescendents
            tooltip: i18n("Subdivide ToDo")
            onClicked: subdivideToDo()
        }
        PlasmaComponents.ToolButton {
            iconSource: "dialog-ok"
            visible: !todoComponent.completed && !hasDescendents
            tooltip: i18n("Mark ToDo as completed")
            onClicked: markAsCompleted()
        }
    }

}
