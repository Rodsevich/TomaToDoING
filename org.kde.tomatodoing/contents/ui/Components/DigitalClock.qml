import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item{

    property alias color: digitalClockText.color

    width: digitalClockText.implicitWidth

    PlasmaCore.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000

        onNewData:{
            var hh = data.DateTime.getHours().toString();
            var mm = (data.DateTime.getMinutes() < 10) ?
                        '0' + data.DateTime.getMinutes().toString()
                      : data.DateTime.getMinutes().toString();
            var ss = (data.DateTime.getSeconds() < 10) ?
                        '0' + data.DateTime.getSeconds().toString()
                      : data.DateTime.getSeconds().toString();
            digitalClockText.text = hh+":"+mm+":"+ss;
        }

    }
    Text {
        id: digitalClockText
        anchors.fill: parent
        color: "red"
        text: "00:00:00"
        font{
            pixelSize: height * 0.85
            family: "Digital Dismay"
        }
    }
}
