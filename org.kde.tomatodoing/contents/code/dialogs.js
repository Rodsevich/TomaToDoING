.pragma library

function dialog(source, message) {
    var dialogLoader = Qt.createQmlObject('import QtQuick 2.5; Loader {}',
        plasmoid.fullRepresentation, "dynamicLoader");
    dialogLoader.onLoaded.connect(function(){
        dialogLoader.item.onStatusChanged.connect(function unloadDialog(){
            if (dialogLoader.item.status == PlasmaComponents.DialogStatus.Closed)
                dialogLoader.source = "";
        });
        dialogLoader.item.open();
    });
    dialogLoader.setSource("Dialogs/" + source, {"messageText":message});
}
