import QtQuick 2.5
import org.kde.plasma.plasmoid 2.0
import QtQuick.Controls 1.4 as QtControls
import org.kde.plasma.core 2.0 as PlasmaCore
import QtQuick.Controls.Styles 1.4 as QtControlsStyles
import org.kde.plasma.components 2.0 as PlasmaComponents

Item{

    property alias maxValue: slider.maximumValue
    property alias minValue: slider.minimumValue
    property alias stepSize: slider.stepSize
    property int value
    property int progressX
    property bool inveseValueBehavior: true
    property bool timeDisplayVisible: true

    property string imgPath: plasmoid.file("images", "trayIcons.svg")
    property string elementId: "tomatoid-running"
    property color sliderColor: "pink"

    QtControls.Slider{
        id: slider
        anchors.fill: parent
        stepSize: 1.0
        value: {
            if(inveseValueBehavior)
                return maximumValue - parent.value;
            else
                return parent.value;
        }
        style: QtControlsStyles.SliderStyle {
            groove: Item{
                Rectangle { //fondo
                    implicitHeight: 6
                    radius: 8
                    color: sliderColor
                    width: parent.parent.parent.width
                }
                Rectangle{ //highlight, de lo ya recorrido
                    implicitHeight: 6
                    radius: 8
                    color: Qt.lighter(sliderColor, 1.25)
                    width: styleData.handlePosition
                }
            }
            handle: PlasmaCore.SvgItem {
                id: icono
                svg: PlasmaCore.Svg {
                    imagePath: imgPath
                }
                elementId: elementId
            }
        }
        height: 10
    }

    implicitHeight: 40

    //for debugging purposes
    property alias d: dsply
    property alias s: slider

    onValueChanged: {
        progressX = (inveseValueBehavior) ?
                    width / (maxValue - minValue) * (maxValue - value - minValue) + 2
                  : width / (maxValue - minValue) * (value - minValue) + 2
    }

    TimeDisplay{
        id: dsply
        visible: timeDisplayVisible
        x: progressX - width / 2;
        width: 40
        height: width / 2
        anchors.bottom: slider.top
//        anchors.topMargin: 10
        seconds: slider.value
    }
}
