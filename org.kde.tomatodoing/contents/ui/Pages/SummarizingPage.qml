import QtQuick 2.0
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.2 as QtControls
import QtQuick.Controls.Styles.Plasma 2.0 as Styles
import org.kde.plasma.private.filecalendarplugin 0.1
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../../code/logic.js" as Logic
import "../../code/enums.js" as Enums

GeneralStatePage{

    registryState: Enums.RegistryTypes.SUMMARIZING

    startingFunction: Logic.startSummarizing
    endingFunction: Logic.endSummarizing

    property bool editedProgress: false

    ColumnLayout{
        anchors.fill: parent
        PlasmaComponents.Label{
            id: summaryText
            text: root.currentTodo.summary
            anchors{
                horizontalCenter: parent.horizontalCenter
            }
            horizontalAlignment: Text.AlignHCenter
            style: Text.Raised
            Layout.fillWidth: true
            font{
                underline: true
                pointSize: 22
                capitalization: Font.Capitalize
                bold: true
            }
        }
        PlasmaComponents.TextArea {
            id: descriptionText
            Layout.fillHeight: true
            text: root.currentTodo.description
            placeholderText: "Description"
            onTextChanged: root.currentTodo.description = text
        }
        RowLayout{
            Layout.maximumHeight: 50
            PlasmaComponents.Label{
                id: percentageLabel
                text: "Completed %: "
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth
            }
            PlasmaComponents.Slider{
                id: percentageSlider
                maximumValue: 100
                minimumValue: 0
                value: root.currentTodo.percentCompleted || 0
                stepSize: 1.0
                Layout.fillHeight: true
                Layout.fillWidth: true
                onValueChanged: {
                    editedProgress = true;
                    percentageSpinBox.value = value
                    root.currentTodo.percentCompleted = value
                }
            }
            QtControls.SpinBox{
                id: percentageSpinBox
                suffix: "%"
                minimumValue: 0
                maximumValue: 100
                value: root.currentTodo.percentCompleted || 0
                Layout.fillHeight: true
                Layout.maximumWidth: 55
                onValueChanged: {
                    editedProgress = true;
                    percentageSlider.value = value
                    root.currentTodo.percentCompleted = value
                }
            }
        }
        RowLayout{
            Layout.preferredHeight: 50
            Layout.margins: 10
            PlasmaComponents.ToolButton{
                Layout.margins: 10
                text: "Skip break"
                iconSource: "media-seek-forward"
                enabled: editedProgress
                onClicked: callEndingFunction(Enums.SummarizingStatus.SKIP_BREAK)
            }

            PlasmaComponents.ToolButton{
                Layout.margins: 10
                text: "Take that break!"
                iconSource: "player-time"
                enabled: editedProgress
                onClicked: callEndingFunction(Enums.SummarizingStatus.TAKE_BREAK)
            }
        }
    }

    Component.onCompleted: editedProgress = false
}
