import QtQuick 2.5
import QtWebKit 3.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrols 2.0 as KQuickControls
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.filecalendarplugin 0.1

import "../Miscellaneous"
import "../Components"
import "../../code/localStorage.js" as DB
import "../../code/logic.js" as Logic
import "../../code/enums.js" as Enums

GeneralStatePage{

    registryState: Enums.RegistryTypes.WORKING

    startingFunction: Logic.startWorking
    endingFunction: Logic.endWorking

    //Debug props
    property alias goalDisplay: pomosGoalDisplay
    property alias clock: digitalClock
    property alias slider: timeSlider
    property alias icono: tomateIcon

//    Timer{
//        interval: 2 * 1000
//        repeat: true
//        onTriggered: main.debug("¡¡¡IDLE!!! ¡LABURA HDP!")
//    }

    id: workingPage

    property int currentPomoCount: root.todayStatistics.pomoCount
    property int totalPomoCount: root.pomodorosGoal
    property int secondsDuration: root.pomodoroLength
    property int currentSeconds: root.timer.seconds
    property int firstRowHeight: 50
    property string todoExplorerParentUid: ""

    PlasmaCore.SvgItem {
        id: tomateIcon
        width: firstRowHeight
        height: firstRowHeight
        anchors{
            top: workingPage.top
            left: workingPage.left
        }
        svg: PlasmaCore.Svg {
            imagePath: plasmoid.file("images", "trayIcons.svg") // "../images/tomatoid.svgz" // "../images/tomatoes-" + sourceIcon + ".svg"
        }
        elementId: "tomatoid-running"
    }
    PlasmaComponents.Label{
        id: pomosGoalDisplay
        height: firstRowHeight
        anchors{
            top: workingPage.top
            left: tomateIcon.right
        }
        text: currentPomoCount + " / " + totalPomoCount
        font{
            weight: Font.Medium
            pixelSize: firstRowHeight / 2
        }
    }
    
    DigitalClock{
        id: digitalClock
        anchors{
            top: parent.top
            right: parent.right
        }
        height: firstRowHeight
//        width: implWidth
    }

    PlasmaComponents.PageStack{
        id: workingPageContent
        visible: !tomateImg.visible
        anchors{
            left: parent.left
            top: pomosGoalDisplay.bottom
            bottom: timeSlider.top
            right: actionsColumn.left
        }
        initialPage: todoResumeView
    }

    Component{
        id: todoExplorerView

        ColumnLayout{
            property int breakSecs

            anchors.fill: parent

            ToDosList{
                Layout.fillWidth: true
                Layout.fillHeight: true
                parentTodoUid: todoExplorerParentUid
                newToDosEnabled: true
                onTodoDoubleClicked: {
                    root.currentTodo = clickedTodo;
                    workingPageContent.replace(todoResumeView);
                }
            }

//            PlasmaComponents.Button{
//                Layout.fillWidth: true
//                Layout.preferredHeight: 30
//                text: "Take a "+Qt.formatTime(new Date(0,0,0,0,0, breakSecs), "mm:ss")+ " break"
//                onClicked: callEndingFunction(Logic.WorkingStatus.ENDED_FROM_FULL_REPRESENTATION);
//            }

//            Component.onCompleted: {
//                breakSecs = root.shortBreakLength * (root.timer.seconds / root.pomodoroLength);
//            }
        }
    }

    Component{
        id: todoResumeView
        Item{
            anchors.fill: parent
            Rectangle{
                anchors.fill: parent
                color: theme.viewBackgroundColor
                border{
                    color: theme.buttonBackgroundColor
                    width: 5
                }
                radius: 10
            }

            PlasmaComponents.Label{
                id: summaryText
                text: root.currentTodo.summary
                anchors{
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
                horizontalAlignment: Text.AlignHCenter
                style: Text.Raised
                font{
                    underline: true
                    pointSize: 22
                    capitalization: Font.Capitalize
                    bold: true
                }
            }
            Text{
                id: descriptionText
                text: root.currentTodo.description
                anchors{
    //                horizontalCenter: parent.horizontalCenter
                    margins: 10
                    top: summaryText.bottom
                    topMargin: 15
                    right: parent.right
                    left: parent.left
                }
                wrapMode: Text.WordWrap
                color: theme.complementaryTextColor
                font{
                    italic: true
                    pointSize: 14
                }
            }
            PlasmaComponents.ProgressBar{
                id: progressBar
                value: root.currentTodo.percentCompleted
                minimumValue: 0
                maximumValue: 100
                anchors{
                    bottom: parent.bottom
                    right: percentageLabel.left
                    left: parent.left
                    margins: 10
                }
            }
            PlasmaComponents.Label{
                id: percentageLabel
                anchors{
                    bottom: progressBar.bottom
    //                baseline: progressBar.baseline
                    right: parent.right
                }
                text: root.currentTodo.percentCompleted + "%"
                width: theme.mSize(theme.defaultFont).width * 4
            }
        }
    }

    Column{
        id: actionsColumn
        visible: !tomateImg.visible
        anchors{
            top: digitalClock.bottom
            right: workingPage.right
        }
        width: 50

        PlasmaComponents.ToolButton{
            iconSource: "emblem-important"
            tooltip: "Drop this Pomodoro"
            onClicked: callEndingFunction(Enums.WorkingStatus.DROP)
            width: parent.width
            height: parent.width
        }

        PlasmaComponents.ToolButton{
            iconSource: "emblem-checked"
            tooltip: "Finish this ToDo"
            width: parent.width
            height: parent.width
            onClicked: {
                root.currentTodo.completed = true;
                todoExplorerParentUid = root.currentTodo.parentUid;
                root.calendarObject.saveCalendar();
                root.currentTodo = root.dummyTodo;
                workingPageContent.replace(todoExplorerView);
            }
        }

        PlasmaComponents.ToolButton {
            iconSource: "layer-lower"
            tooltip: i18n("Subdivide ToDo")
            width: parent.width
            height: parent.width
            onClicked: {
                todoExplorerParentUid = root.currentTodo.uid;
                workingPageContent.replace(todoExplorerView);
            }
        }

        PlasmaComponents.ToolButton{
            iconSource: "tool_pen"
            tooltip: "Create note (not implemented yet)"
            width: parent.width
            height: parent.width
            onClicked: main.debug("crear nota")
        }

    }

    TomateSlider{
        id: timeSlider
        width: parent.width * 0.8
        value: currentSeconds
        minValue: 0
        maxValue: secondsDuration
        imgPath: plasmoid.file("images", "trayIcons.svg")
        sliderColor: "blue"
//        height: 30
        anchors{
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            bottomMargin: 7
        }
    }

    TomateImage{
        id: tomateImg
        anchors.fill: parent
        text: root.timer.seconds
        tomateImageColor: Enums.TomateImageColor.RED
        state: "almostRinging"
        visible: false
        onTomateClicked: {
            root.preventRing = true;
            visible = false;
        }
    }

    Connections{
        target: root.timer
        onTick: root.tickingSound.play()
        onAlertBeforeTimeout: {
            tomateImg.visible = true;
            if(!plasmoid.expanded){
                root.knockSound.play();
                plasmoid.expanded = true;
            }
        }
        onTimeout: callEndingFunction(Enums.WorkingStatus.TIMEOUT);
//        onTimeout: timeoutHandler()
    }

    function mainActionButtonClickHandler(){
        callEndingFunction(Enums.WorkingStatus.PAUSE);
    }

//    function timeoutHandler(){
//        callEndingFunction(Enums.WorkingStatus.TIMEOUT);
//    }
}
