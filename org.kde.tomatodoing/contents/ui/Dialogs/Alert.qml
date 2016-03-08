import QtQuick 2.0
import QtMultimedia 5.5

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons

// DialogContent

PlasmaComponents.Dialog {

    id: dialog

    property string messageText: "Message"
    property int widthSize: 400

    location: PlasmaCore.Types.Floating

    title: Item {
        width: widthSize
        height: widthSize * 0.2
        PlasmaExtras.Title {
            text: "Alert!"
            horizontalAlignment: Text.AlignHCenter
        }
    }

    content: Item {
        width: widthSize
        height: widthSize * 0.5
        PlasmaExtras.Heading {
            level: 2
            text: dialog.messageText
            horizontalAlignment: Text.AlignHCenter
        }
    }

    buttons: PlasmaComponents.ButtonRow {
        PlasmaComponents.Button {
            text: "Ok"
            iconSource: "dialog-ok"
            onClicked: {
                dialog.accept();
            }
        }
    }

    onStatusChanged: {
        if (status == PlasmaComponents.DialogStatus.Open)
            errorSound.play()
    }

    SoundEffect{
        id: errorSound
        source: "../../data/access-denied.wav"//plasmoid,file("data", "access-denied.wav")
    }
}
