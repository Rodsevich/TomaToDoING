import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../../code/enums.js" as Enums

PlasmaComponents.Page {

    anchors.fill: parent

    //No parece funcar con lo que quiero...
//    implicitHeight: parent.implicitHeight
//    implicitWidth: parent.implicitWidth

    property var registryState: Enums.RegistryTypes.MASK
    property var startingFunction
    property var endingFunction

    function signalize(name, args){
        console.log("signalHandler called and not reimplemented.")
        console.trace();
        return false;
    }

    function callEndingFunction( estado ){
        if(registryState === Enums.RegistryTypes.MASK){
            console.trace();
            throw "Must define registryState!";
        }
        if(typeof endingFunction !== "function"){
            console.trace();
            throw "Must define an endingFunction";
        }
        endingFunction(registryState | estado);
    }

    function mainActionButtonClickHandler(){
        console.log("mainActionButtonClickHandler called and not reimplemented.")
        return false;
    }
}
