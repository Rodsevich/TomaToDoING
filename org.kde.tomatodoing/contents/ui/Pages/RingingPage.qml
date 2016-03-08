import QtQuick 2.0
import "../../code/enums.js" as Enums
import "../../code/logic.js" as Logic
import "../Miscellaneous"

GeneralStatePage{

    registryState: Enums.RegistryTypes.RINGING

    startingFunction: Logic.startRinging
    endingFunction: Logic.endRinging

    TomateImage{
        anchors.fill: parent
        textVisible: false
        state: "ringing"
        onTomateClicked: {
            root.ringSound.stop();
            callEndingFunction(Enums.RingingStatus.CLICKED_IN_FULL_REPRESENTATION);
        }
    }

    function mainActionButtonClickHandler(){
        root.ringSound.stop();
        callEndingFunction(Enums.PauseStatus.MAIN_ACTION_BUTTON_CLICKED);
    }

    Component.onCompleted: {
        if(root.preventRing)
            root.preventRing = false;
        else
            root.ringSound.play()
    }
}
