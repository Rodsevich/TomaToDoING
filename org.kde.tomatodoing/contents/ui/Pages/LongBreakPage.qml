import QtQuick 2.0
import "../../code/logic.js" as Logic
import "../../code/enums.js" as Enums

ShortBreakPage{
    registryState: Enums.RegistryTypes.LONG_BREAK

    startingFunction: Logic.startLongBreak
    endingFunction: Logic.endLongBreak
}
