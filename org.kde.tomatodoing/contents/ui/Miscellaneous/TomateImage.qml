import QtQuick 2.0
import "../../code/logic.js" as Logic
import "../../code/enums.js" as Enums

Item {

    id: mainItem

    property real almostRingingScale: 1.05
    property int ringingRotation: 10
    property string tomateImageSource: ""
    property int tomateImageColor: Enums.TomateImageColor.RED
    property alias text: secondsLeftSign.text
    property alias textVisible: secondsLeftSign.visible

    signal tomateClicked()

    state: ""//ringing | almostRinging

    Item {
        id: tomate
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: parent.height * 0.8

        Image {
            id: tomateImage
            z: -1
            anchors.fill: tomate
            opacity: root.timer.seconds <= 60 ? 0.7 : 0.25
            source: {
                if(tomateImageSource !== "")
                    return tomateImageSource;
                switch(tomateImageColor){
                    case Enums.TomateImageColor.RED:
                        return "../../images/tomatoid-icon-red.png"
                    case Enums.TomateImageColor.YELLOW:
                        return "../../images/tomatoid-icon-yellow.png"
                    case Enums.TomateImageColor.GREEN:
                        return "../../images/tomatoid-icon-green.png"
                }
            }
        }

        Text {
            id: secondsLeftSign
            text: root.timer.seconds
            visible: root.timer.seconds <= 60
            color: "#AACCDD"
            anchors.centerIn: tomateImage
            font.pixelSize: 52
            font.bold: true
        }
    }

    SequentialAnimation {
        id: aboutToRingAnimation
        alwaysRunToEnd: true
        running: false
        loops: Animation.Infinite


        NumberAnimation {
            target: tomate
            property: "scale"
            duration: 150
            easing.type: Easing.InOutQuad
            to: almostRingingScale
        }

        NumberAnimation {
            target: tomate
            property: "scale"
            duration: 50
            easing.type: Easing.InOutQuad
            to: 1
        }
    }

    SequentialAnimation {
        id: ringingAnimation
        running: false
        loops: Animation.Infinite


        NumberAnimation {
            target: tomate
            property: "rotation"
            duration: 42 // 1000(ms)/24(fps)= ~42ms per frame
            to: ringingRotation
        }

        NumberAnimation {
            target: tomate
            property: "rotation"
            duration: 42 // 1000(ms)/24(fps)= ~42ms per frame
            to: ringingRotation * -1
        }
    }

//    ParallelAnimation { //The parallel animation starts over again only when the longests animation ends
//        id: aboutToRingAnimation
//        alwaysRunToEnd: true
//        running: false
//        loops: Animation.Infinite

//        SequentialAnimation {
//            alwaysRunToEnd: true
//            NumberAnimation {
//                alwaysRunToEnd: true
//                target: tomate
//                property: "scale"
//                duration: 450
//                easing.type: Easing.InOutQuart
//                to: almostRingingScale
//            }
//            NumberAnimation {
//                alwaysRunToEnd: true
//                target: tomate
//                property: "scale"
//                duration: 50
//                easing.type: Easing.InOutQuart
//                to: 1
//            }
//        }

//        SequentialAnimation {
//            alwaysRunToEnd: true
//            RotationAnimation {
//                alwaysRunToEnd: true
//                target: tomate
//                property: "rotation"
//                duration: 125
//                to: 5
//            }
//            RotationAnimation {
//                alwaysRunToEnd: true
//                target: tomate
//                property: "rotation"
//                duration: 125
//                to: -15
//            }
//            RotationAnimation {
//                alwaysRunToEnd: true
//                target: tomate
//                property: "rotation"
//                duration: 125
//                to: 15
//            }
//            RotationAnimation {
//                alwaysRunToEnd: true
//                target: tomate
//                property: "rotation"
//                duration: 125
//                to: -5
//            }
//        }
//    }

    states: [
        State {
            name: "ringing"
            PropertyChanges {
                target: ringingAnimation
                running: true
            }
//            onCompleted: {
//                parent.state = "ringing2"
//            }
        },
//        State {
//            name: "ringing2"
//            PropertyChanges {
//                target: tomate
//                rotation: fullMouseArea.containsMouse ? -3 : -10
//            }
//            onCompleted: {
//                parent.state = "ringing"
//            }
//        },
        State {
            name: "almostRinging"
            PropertyChanges {
                target: aboutToRingAnimation
                running: true
            }
//            PropertyChanges {
//                target: secondsLeftSign
//            }
        }
    ]
//    transitions: [
//        Transition {
//            RotationAnimation {
//                duration: 100
//                direction: RotationAnimation.Shortest
//            }
//        }
//    ]

    MouseArea {
        id: fullMouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onClicked: {
            tomateClicked()
        }
        onContainsMouseChanged: {
            if(containsMouse)
                ringingRotation = 3;
            else
                ringingRotation = 10;
        }
    }
}
/* Como usar scripts en los States */

//State {
//    name: "state1"
//    StateChangeScript {
//        name: "myScript"
//        script: doStateStuff();
//    }
//    // ...
//}
//// ...
//Transition {
//    to: "state1"
//    SequentialAnimation {
//        NumberAnimation { /* ... */ }
//        ScriptAction { scriptName: "myScript" }
//        NumberAnimation { /* ... */ }
//    }
//}
