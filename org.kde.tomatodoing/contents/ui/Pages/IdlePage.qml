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

}
