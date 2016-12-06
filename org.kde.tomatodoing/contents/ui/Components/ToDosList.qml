//Highly "inspired" (if not copied) from org.kde.plasma.clipboard

import QtQuick 2.5
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.0
import QtQuick.Controls 1.0 as QtControls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.filecalendarplugin 0.1
import org.kde.plasma.components 2.0 as PlasmaComponents

import "../Dialogs"

Item {

    id: todoList

    signal todoClicked(CalendarToDo clickedTodo);
    signal todoDoubleClicked(CalendarToDo clickedTodo);
//    property alias currentToDo: todosView.currentItem.todoComponent
    property alias currentItem: todosView.currentItem
    property alias newToDosEnabled: newToDosComponent.active
    property alias parentTodoUid: toDoNavModel.currentParentUid

    property FileCalendar fileCalendarComponent: root.calendarObject

    Connections{
        target: fileCalendarComponent
        onFileChanged: fileCalendarComponent.loadCalendar()
        onTodosChanged: toDoNavModel.reload()
    }

    ListModel {
        id: toDoNavModel
        property string currentParentUid: ""
        property var todos: todosComponents()

        onCurrentParentUidChanged: {
            clear();
            var uid = currentParentUid;
            while(uid !== ""){
                var comp = fileCalendarComponent.componentByUid(uid);
                append({"uid":comp.uid, summary: comp.summary});
                uid = comp.parentUid;
            }
//            //Reverse the elements
            for(var i = 0; i < count - 1; i++)
                move(count - 1, i, 1);
            todos = todosComponents();
            todosView.currentIndex = -1;
        }

        function resetTo(index){
            var cant = count - 1 - index;
            remove(index + 1, cant);
            var lastElem = get(count - 1);
            currentParentUid = lastElem ? lastElem.uid : "";
        }

        function reload(){
            todos = todosComponents();
        }

        function todosComponents(){
            var filtered = [];
            for (var i in fileCalendarComponent.todos){
                if(fileCalendarComponent.todos[i].parentUid === currentParentUid){
                    if(fileCalendarComponent.todos[i].completed)
                        if(fileCalendarComponent.todos[i].completedDate.toDateString() !== new Date().toDateString())
                            continue; //If not completed today, better filter it out
                    filtered.push(fileCalendarComponent.todos[i]);
                }
            }
            return filtered;
        }
    }

    //current.tdl.lista.children[0].children[4].children[2]
    //current.tdl.fc.todos[3].parentUid
    //current.tdl.fc.componentByUid("d6d1e38b-9b0b-4621-b0e0-a712c127b9d4")
    //current.tdl.fc.componentByUid("86d0a32d-de2d-4a8c-bb82-b3f29aac701f").padre

    Column {
        anchors {
            fill: parent;
        }
        Flickable {
            id: explorerMenuScrollArea
            visible: toDoNavModel.count > 0
            anchors {
                left: parent.left
                right: parent.right
            }
            height: todoRow.height
            Item {
                width: Math.max(parent.width, todoRow.width)
                height: todoRow.height

                Row {
                    id: todoRow
                    PlasmaComponents.ButtonRow {
                        spacing: 0
                        exclusive: true

                        PlasmaComponents.ToolButton {
                            flat:false;
                            iconSource: "go-previous"
                            onClicked: toDoNavModel.resetTo(toDoNavModel.count - 2)
                        }

                        PlasmaComponents.ToolButton {
                            flat:false
                            iconSource: "edit-delete"
                            onClicked: toDoNavModel.currentParentUid = ""
                        }

                        PlasmaComponents.ToolButton {
                            flat:false;
                            iconSource: "view-refresh"
                            onClicked: {fileCalendarComponent.loadCalendar();toDoNavModel.reload()}
                        }

                        Repeater{
                            model: toDoNavModel
                            delegate: PlasmaComponents.ToolButton {
                                flat:false
                                text: model.summary
                                width: text.length * theme.mSize(theme.defaultFont).width
                                onClicked: toDoNavModel.resetTo(index)
                            }
                        }
                    }
                }
            }
        }

        ListView{
            id: todosView
            property bool freezedItem: false
            focus: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentHeight > height
            highlight: PlasmaComponents.Highlight { }
            highlightMoveDuration: 0
            highlightResizeDuration: 0
            currentIndex: -1
            cacheBuffer: 4
            model: toDoNavModel.todos
            width: parent.width
            height: Math.max(contentHeight, 300)
            delegate: ToDoListViewDelegate {
                width: parent.width
                onClicked: {
                    //View item: ListView.view
                    //delegate item: this
                    //todoComponent: this.todoComponent
                    if(hasDescendents)
                        toDoNavModel.currentParentUid = model.modelData.uid;
                    else{
                        if(ListView.view.currentIndex === index){
                            ListView.view.freezedItem = !ListView.view.freezedItem;
                        }
                        ListView.view.currentIndex = index;
                        todoClicked(this.todoComponent);
                    }
                }
                onDoubleClicked: {
                    todoDoubleClicked(this.todoComponent)
                }
                onPressAndHold: {
                    editDialog.edit(model.modelData)
                }
                onMarkAsCompleted: {
                    model.modelData.completed = true;
                    fileCalendarComponent.saveCalendar();
                }
                onSubdivideToDo: {
                    toDoNavModel.currentParentUid = model.modelData.uid
                }
                onEditToDo: {
                    editDialog.edit(model.modelData)
                }
                onDeleteToDo: {
                    var calendarTodo = model.modelData;
                    var debug = function(arg){return console.log(arg)};
                    var guardar = fileCalendarComponent.saveCalendar;
                    var obtainComponent = fileCalendarComponent.componentByUid;
                    var currentParentUid = toDoNavModel.currentParentUid;
                    debug("Model: "+model)
                    debug("ModelData: "+calendarTodo)
                    debug("Borrando summary: "+calendarTodo.summary)
                    //Delete references to this Element
                    if(calendarTodo.parentUid !== ""){
                        var parent = obtainComponent(currentParentUid);
                        debug("El parent es: "+parent.summary);
                        if(parent.childUid === calendarTodo.uid){
                            debug("El parent tenia el childUid del mismo ToDo: "+calendarTodo.uid);
                            parent.childUid = calendarTodo.siblingUid;
                        }
                        else if(parent.childUid !== ""){
                            var lastChildComponent = obtainComponent(parent.childUid);
                            debug("el primer hijo es: "+lastChildComponent)
                            while(lastChildComponent.siblingUid !== calendarTodo.uid)
                                lastChildComponent = obtainComponent(lastChildComponent.siblingUid);
                            lastChildComponent.siblingUid = calendarTodo.siblingUid;
                        }else
                            parent.childUid = calendarTodo.siblingUid;
                    }
                    if(fileCalendarComponent.deleteIncidenceByUid(calendarTodo.uid))
                        guardar();
                    else
                        debug("borrado = False");
//                        fileCalendarComponent.loadCalendar();
//                        toDoNavModel.reload();
                }
            }
        }
        Loader{
            id: newToDosComponent
            active: false
            sourceComponent:
                Component {
                    Item {
                        property bool withFocus: newToDoPriority.focus || newToDoSummary.focus
                        width: todosView.width
                        height: Math.max(newToDoPriority.implicitHeight, newToDoSummary.implicitHeight)
                        property alias newToDoSummary: sum
                        property alias newToDoPriorityLabel: lbl
                        property alias newToDoPriority: prt
                        PlasmaComponents.TextField{
                            id: sum
                            height: parent.height
                            anchors{
                                top: parent.top
                                right: newToDoPriorityLabel.left
                                left: parent.left
                            }
                            text: todoComponent.summary
                            placeholderText: "New ToDo"
                        }
                        PlasmaComponents.Label{
                            id: lbl
                            anchors{
                                top: parent.top
                                right: newToDoPriority.left
                            }
                            text: "PRty: "
                            width: implicitWidth
                            height: parent.height
                            font.pointSize: theme.smallestFont.pointSize
                        }
                        PlasmaComponents.TextField{
                            id: prt
                            width: theme.mSize(theme.defaultFont).width + __style.padding.left + __style.padding.right
                            height: parent.height
                            anchors{
                                top: parent.top
                                right: parent.right
                            }
                            property int minimumValue: 1
                            property int maximumValue: 9
                            property int value: todoComponent.priority || 5
                            text: value.toString()
                            onValueChanged: {
                                if(value > maximumValue)
                                    value = maximumValue;
                                else if(value < minimumValue)
                                    value = minimumValue;
                                text = value.toString();
                            }
                        }
                    }
                }
        }
    }

    //ToDo Editor

    TodoEditDialog{
        id: editDialog
        onAccepted: fileCalendarComponent.saveCalendar();
    }

    //ToDo Creator:

    property CalendarToDo todoComponent

    Component{
        id: toDoFactory

        CalendarToDo{
            description: "Fast-created with TomaToDoING. "
        }
    }

    function makeNewToDo(){
        todoComponent = toDoFactory.createObject(todoList);
    }

    Component.onCompleted: {
        makeNewToDo();
    }

    focus: true
    Keys.onPressed: {
        switch(event.key) {
            case Qt.Key_Up:
                if( newToDosComponent.item.withFocus )
                    newToDosComponent.item.newToDoPriority.value--
                else
                    todosView.decrementCurrentIndex();
                event.accepted = true;
            break;
            case Qt.Key_Down:
                if( newToDosComponent.item.withFocus )
                    newToDosComponent.item.newToDoPriority.value++
                else
                    todosView.incrementCurrentIndex();
                event.accepted = true;
            break;
            case Qt.Key_Enter:
            case Qt.Key_Return:
//                console.log("enter apretado");
//                console.log("Objeto de newToDosComponent.item (focus:"+newToDosComponent.item.withFocus+"): "+newToDosComponent.item);
                if(newToDosEnabled){
                    createNewToDo();
                }
                event.accepted = true;
            break;
        }
    }

    function createNewToDo(){
        console.log("Entre a createNewToDo()");
        console.log("newToDosComponent.item.withFocus: "+newToDosComponent.item.withFocus);
        console.log("newToDosComponent.item.newToDoSummary.text: "+newToDosComponent.item.newToDoSummary.text);
        if( newToDosComponent.item.withFocus && newToDosComponent.item.newToDoSummary.text !== ""){
            if(toDoNavModel.currentParentUid !== ""){
                var parent = fileCalendarComponent.componentByUid(toDoNavModel.currentParentUid);
                console.log("El parent es: "+parent.summary);
                if(parent.childUid === ""){
                    console.log("El parent no tenia childUid asi que le asigné: "+todoComponent.uid);
                    parent.childUid = todoComponent.uid;
                }
                else{
                    var lastChildComponent = fileCalendarComponent.componentByUid(parent.childUid);
                    while(lastChildComponent.siblingUid !== "")
                        lastChildComponent = fileCalendarComponent.componentByUid(lastChildComponent.siblingUid);
                    console.log("El ultimo sibling es: "+lastChildComponent.summary+" y se le asigna "+todoComponent.uid);
                    lastChildComponent.siblingUid = todoComponent.uid;
                }
                todoComponent.parentUid = toDoNavModel.currentParentUid;
            }
            todoComponent.summary = newToDosComponent.item.newToDoSummary.text;
            todoComponent.priority = newToDosComponent.item.newToDoPriority.value;
            todoComponent.description = todoComponent.description + new Date();
            todoComponent.percentCompleted = 0;
            fileCalendarComponent.addToDo(todoComponent);
            fileCalendarComponent.saveCalendar();
            makeNewToDo();
            toDoNavModel.reload();
        }
    }
}
//      Test ToDo Data for FileCalendar
//            todos: [
//                CalendarToDo{
//                    priority: 1
//                    summary: "sorpi1"
//                    percentCompleted: 100
//                },
//                CalendarToDo{
//                    priority: 2
//                    summary: "sorpi2"
//                    percentCompleted: 46
//                }
//            ]
