import QtQuick 2.5

Item {
    id: displayItem

    property int seconds: 1457

    property string timeString: Qt.formatTime(new Date(0,0,0,0,0, seconds), "mm:ss")

    Rectangle {
        id: displayBackground
        // should be 40 when size is 90
        width: Math.max(parent.width*4/9, 36)
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
        id: displayText
        text: timeString
        color: theme.textColor
        font.pixelSize: Math.max(displayItem.size/8, 11)
        anchors.centerIn: displayBackground
        opacity: displayBackground.opacity > 0 ? 1 : 0
    }

    MouseArea{
        id: mouseArea
        hoverEnabled: true
        anchors.centerIn: parent
    }
}
