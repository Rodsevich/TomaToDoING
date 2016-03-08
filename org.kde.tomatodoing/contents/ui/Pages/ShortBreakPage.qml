import QtQuick 2.0
import "../../code/logic.js" as Logic
import "../../code/enums.js" as Enums
import "../Miscellaneous"

GeneralStatePage{

    registryState: Enums.RegistryTypes.SHORT_BREAK

    startingFunction: Logic.startShortBreak
    endingFunction: Logic.endShortBreak

    TomateImage{
        anchors.fill: parent
        text: root.timer.seconds
        tomateImageColor: Enums.TomateImageColor.GREEN
        state: ""
        onTomateClicked: {
            callEndingFunction(Enums.BreakStatus.CLICKED_IN_FULL_REPRESENTATION);
        }
    }

    function mainActionButtonClickHandler(){
        callEndingFunction(Enums.BreakStatus.MAIN_ACTION_BUTTON_CLICKED);
    }

    Connections{
        target: root.timer
        onTimeout: timeoutHandler()
    }

    function timeoutHandler(){
        callEndingFunction(Enums.BreakStatus.TIMEOUT);
    }
}
