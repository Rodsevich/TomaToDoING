import QtQuick 2.0
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.2 as QtControls
import QtQuick.Controls.Styles.Plasma 2.0 as Styles
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.filecalendarplugin 0.1
import org.kde.plasma.components 2.0 as PlasmaComponents

// DialogContent

PlasmaComponents.Dialog {

    id: editDialog

    property CalendarToDo todoComponent: CalendarToDo { }
    property int widthSize: 350
    property string action: "Edit"
    property var initialValues: {
        "summary":null,
        "description":null,
        "priority":null,
        "percentCompleted":null
    }

    location: PlasmaCore.Types.Desktop

    title: Item {
        width: widthSize
        height: widthSize * 0.2
        PlasmaExtras.Title {
            text: action + " ToDo"
            horizontalAlignment: Text.AlignHCenter
        }
    }

    content: Item {
        width: widthSize
        height: widthSize * 0.43
        ColumnLayout{
            anchors.fill: parent
            RowLayout{
                id: firstRow
                Layout.maximumHeight: 50
                Layout.fillWidth: true
                QtControls.TextField {
                    id: summaryIpt
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: todoComponent.summary
                    placeholderText: "Name"
                    onTextChanged: todoComponent.summary = text
                }
                QtControls.SpinBox{
                    id: priorityIpt
                    Layout.maximumWidth: 55
                    Layout.fillHeight: true
                    minimumValue: 1
                    maximumValue: 9
                    value: todoComponent.priority || 5
                    onValueChanged: todoComponent.priority = value
                }
            }
            PlasmaComponents.TextArea {
                id: descriptionText
                Layout.fillHeight: true
                text: todoComponent.description
                placeholderText: "Description"
                onTextChanged: todoComponent.description = text
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
                    value: todoComponent.percentCompleted || 0
                    stepSize: 1.0
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onValueChanged: {
                        percentageSpinBox.value = value
                        todoComponent.percentCompleted = value
                    }
                }
                QtControls.SpinBox{
                    id: percentageSpinBox
                    suffix: "%"
                    minimumValue: 0
                    maximumValue: 100
                    value: todoComponent.percentCompleted || 0
                    Layout.fillHeight: true
                    Layout.maximumWidth: 55
                    onValueChanged: {
                        percentageSlider.value = value
                        todoComponent.percentCompleted = value
                    }
                }
            }
        }
    }

    buttons: PlasmaComponents.ButtonRow {
        height: 60
        PlasmaComponents.Button {
            text: "Cancel"
            iconSource: "edit-delete"
            onClicked: {
                reject();
            }
        }
        PlasmaComponents.Button {
            text: editDialog.action
            iconSource: "dialog-ok"
            onClicked: {
                accept();
            }
        }
    }

    function edit(todoComp){
        console.log("Llamada a editar con action: "+action,true)
        todoComponent = todoComp;
        initialValues.summary = todoComp.summary;
        initialValues.priority = todoComp.priority;
        initialValues.description = todoComp.description;
        initialValues.percentCompleted = todoComp.percentCompleted;
        this.open();
    }

    onTodoComponentChanged: {
        if (todoComponent.summary.length == 0)
            action = "Create"
    }

    onRejected: {
        todoComponent.summary = initialValues.summary;
        todoComponent.priority = initialValues.priority;
        todoComponent.description = initialValues.description;
        todoComponent.percentCompleted = initialValues.percentCompleted;
    }
}
