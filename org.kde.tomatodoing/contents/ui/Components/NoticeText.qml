import QtQuick 2.0

Item{

    property color backgroundColor: "red"
    property color textColor: "lightblue"
    property string text: "TEXT TO SHOW"

    implicitHeight: fondoTexto.height
    implicitWidth: fondoTexto.width

    Rectangle{
        id: fondoTexto
        width: parent.width
        height: texto.contentHeight + 10
        radius: 10
        gradient: Gradient{
            GradientStop {position: 0.0; color: Qt.lighter(backgroundColor)}
            GradientStop {position: 0.9; color: backgroundColor}
            GradientStop {position: 1.0; color: Qt.darker(backgroundColor)}
        }
    }

    Text{
        id: texto
        color: textColor
        width: fondoTexto.width * 0.85
        anchors.centerIn: fondoTexto
        text: parent.text
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideMiddle
        wrapMode: Text.Wrap
    }
}

