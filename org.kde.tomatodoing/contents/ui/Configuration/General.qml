import QtQuick 2.0
import QtQuick.Layouts 1.0 as QtLayouts
import QtQuick.Controls 1.0 as QtControls
import QtQuick.Controls.Styles 1.4 as QtControlsStyles
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: generalPage
    width: childrenRect.width
    height: childrenRect.height

    signal configurationChanged

    property int cfg_pomodoroLength
    property int cfg_shortBreakLength
    property int cfg_perDayPauseTime
    property int cfg_longBreakLength

    property int maxLabelsWidth: 125

    property var generalModel: [
        {
            name: i18n("Pomodoro duration:"),
            svgName: "tomatoid-running",
            confVar: "cfg_pomodoroLength",
            min: 1,
            max: 60,
            color: "#A70"
        },
        {
            name: i18n("Break duration:"),
            svgName: "tomatoid-break",
            confVar: "cfg_shortBreakLength",
            min: 2,
            max: 12,
            color: "#030"
        },
        {
            name: i18n("Pause duration:"),
            svgName: "tomatoid-paused",
            confVar: "cfg_perDayPauseTime",
            min: 0,
            max: 60,
            color: "#330"
        },
//        {
//            name: i18n("Idle duration:"),
//            svgName: "tomatoid-idle",
//            confVar: cfg_longBreakLength
//        },
    ]

    PlasmaCore.Svg {
        id: tomates
        imagePath: plasmoid.file("images", "trayIcons.svg") // "../images/tomatoid.svgz" // "../images/tomatoes-" + sourceIcon + ".svg"
    }

    QtLayouts.ColumnLayout{

        Repeater{
            model: generalModel
            QtLayouts.RowLayout{

                Component{
                    id: colorTomato
                    PlasmaCore.SvgItem {
                        svg: tomates
                        elementId: model.modelData.svgName
                    }
                }

                QtControls.Label{
                    text: model.modelData.name
                    QtLayouts.Layout.preferredWidth: maxLabelsWidth
                }

                QtControls.Slider{
                    value: generalPage[model.modelData.confVar]
                    minimumValue: model.modelData.min
                    maximumValue: model.modelData.max
                    stepSize: 1.0
                    style: QtControlsStyles.SliderStyle {
                        groove: Rectangle {
                            implicitWidth: (model.modelData.max - model.modelData.min) * 5
                            implicitHeight: 6
                            color: model.modelData.color
                            radius: 8
                        }
                        handle: colorTomato
                    }
                    onValueChanged: generalPage[model.modelData.confVar] = value
                }

                QtControls.SpinBox{
                    value: generalPage[model.modelData.confVar]
                    suffix: "mins."
                    minimumValue: model.modelData.min
                    maximumValue: model.modelData.max
                    onValueChanged: generalPage[model.modelData.confVar] = value
                    anchors.right: generalPage.anchors.right
                }
            }
        }
    }
}
