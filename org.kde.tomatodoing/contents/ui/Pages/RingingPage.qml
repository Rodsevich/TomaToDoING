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
        callEndingFunction(Enums.RingingStatus.MAIN_ACTION_BUTTON_CLICKED);
    }

    Timer{
        id: ringingLimiter
        running: !root.infiniteRinging
        interval: root.ringTime
        onTriggered: {
            root.ringSound.stop();
            callEndingFunction(Enums.RingingStatus.TIMEOUT);
        }
    }

    Component.onCompleted: {
        if(!root.infiniteRinging)
            ringingLimiter.restart();
        root.ringSound.play();
    }
}
