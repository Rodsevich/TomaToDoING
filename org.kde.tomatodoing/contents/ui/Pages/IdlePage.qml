import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../Components"
import "../../code/enums.js" as Enums
import "../../code/logic.js" as Logic

GeneralStatePage{

    registryState: Enums.RegistryTypes.IDLE

    startingFunction: Logic.startIdle
    endingFunction: Logic.endIdle

    ToDosList{
        id: todoList
        newToDosEnabled: true
        anchors.fill: parent
        onCurrentItemChanged: {
            if(currentItem)
                root.currentTodo = currentItem.todoComponent;
        }
        onTodoDoubleClicked: {
            if(clickedTodo.completed === false){
                root.currentTodo = clickedTodo;
                callEndingFunction(Enums.IdleStatus.TODO_DOUBLECLICKED)
            }
        }
    }
    Keys.forwardTo: [todoList]

    function mainActionButtonClickHandler(){
        todoList.createNewToDo();
    }

    function signalize(name, args){
        if(name == "eventAutoStart")
            callEndingFunction(Enums.IdleStatus.SCHEDULED_TODO_START);
    }

    Timer{
        id: maximumIdleTimeModeTimer
        running: root.maxIdleTimeMode
        interval: root.maxIdleMinutes * 60000// 60 seconds * 1000 miliseconds
        onTriggered: callEndingFunction(Enums.IdleStatus.MAX_TIME_EXCEEDED)
    }

    Component.onCompleted: {
        if(root.maxIdleTimeMode)
            maximumIdleTimeModeTimer.restart();
    }

}
