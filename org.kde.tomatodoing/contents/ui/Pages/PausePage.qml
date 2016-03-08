import QtQuick 2.0
import "../../code/logic.js" as Logic
import "../../code/enums.js" as Enums
import "../Miscellaneous"

GeneralStatePage{

    registryState: Enums.RegistryTypes.PAUSE

    startingFunction: Logic.startPause
    endingFunction: Logic.endPause

    TomateImage{
        anchors.fill: parent
        text: root.timer.seconds
        textVisible: root.timer.seconds <= 60
        tomateImageColor: Enums.TomateImageColor.YELLOW
        state: ""
        onTomateClicked: {
            callEndingFunction(Enums.PauseStatus.CLICKED_IN_FULL_REPRESENTATION);
        }
    }

    function mainActionButtonClickHandler(){
        callEndingFunction(Enums.PauseStatus.MAIN_ACTION_BUTTON_CLICKED);
    }

    Connections{
        target: root.timer
        onTimeout: timeoutHandler()
    }

    function timeoutHandler(){
        callEndingFunction(Enums.PauseStatus.TIMEOUT);
    }
}
