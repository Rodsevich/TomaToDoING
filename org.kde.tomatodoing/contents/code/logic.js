/*
 *   Copyright 2013 Arthur Taborda <arthur.hvt@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

.pragma library
.import "localStorage.js" as DB
.import "dialogs.js" as Dialogs
.import "enums.js" as Enums
//Qt.include("enums.js");//So it can be accessed from outside QMLs without enums import

var root;
var plasmoid;
var fullRepresentationPageStack;

//function timerTick() {
//    if(root.inPomodoro){
//        root.resources[3].play();//tick sound
//    }
//}

//function timerTimeout() {
//    if(root.inPomodoro) {
//        root.resources[0].play(); //ring sound
//    }else
//        root.resources[5].play(); //Knock sound
//}

//function timerAlertBeforeTimeout() {
//    console.log("timerAlertBeforeTimeout");
//    if(root.inPomodoro){
//        plasmoid.status = PlasmaCore.Types.RequiresAttentionStatus;
//        if(!plasmoid.expanded){
//            root.resources[5].play(); //Knock sound
//            plasmoid.expanded = true;
//        }
//        root.state = Enums.States.ALMOST_RINGING;
//    }
//}

//function resumePause(){
//    root.currentPauseTime = timer.seconds;
//    timer.seconds = root.currentPomodoroTime;
//    DB.finishCurrentRegistry(root.currentPauseRowID);
//    root.state = "working";
//}

//State management exclusive functions

//function ring(){
//    root.resources[0].play(); //ring sound
//    root.state = "ringing";
//}

//function endRinging(){
//    root.resources[0].stop(); //ring sound
//    startBreak();
//}

function startIdle(){ //Executed when main button pressed
    root.state = Enums.States.IDLE;
    fullRepresentationPageStack.replace(root.idlePage);
    return true;
}

function endIdle(idleStatus){
    root.handleStateFinish(Enums.States.IDLE,idleStatus);
}

function startWorking(time){
    root.timer.totalSeconds = (typeof time !== "undefined") ? time : root.pomodoroLength;
    fullRepresentationPageStack.replace(root.workingPage);
    root.currentRowID = DB.start(Enums.RegistryTypes.WORKING, root.currentTodo);
    root.state = Enums.States.WORKING;
    return true;
}

function endWorking(workingStatus) {
    var type = statusType(workingStatus);
    switch(type){
        case Enums.Statuses.NORMAL_END:
            root.todayStatistics.pomoCount++;
        case Enums.Statuses.CORRECT_END:
            var workedTime = root.pomodoroLength - root.timer.seconds;
            root.todayStatistics.pomoTime += workedTime;
        case Enums.Statuses.INCORRECT_END:
            DB.finishCurrentRegistry(root.currentRowID,workingStatus);
    }
    root.handleStateFinish(Enums.States.WORKING,workingStatus);
}

function startPause(){ //Executed when main button pressed
    if( root.currentPauseTime === -1 ){
        root.currentPauseTime = root.perDayPauseSeconds;
        return startPause();
    } else if( root.currentPauseTime > 0 ){
        root.currentPomodoroTime = root.timer.seconds;
        root.timer.seconds = root.currentPauseTime;
        fullRepresentationPageStack.replace(root.pausePage);
        root.state = Enums.States.PAUSE;
        root.currentPauseRowID = DB.start(Enums.RegistryTypes.PAUSE, root.currentTodo);
        return true;
    }else{
        return false;
    }
}

function endPause(pauseStatus){
    switch(statusType(pauseStatus)){
        case Enums.Statuses.CORRECT_END: //=== Statuses.PauseStatus.TIMEOUT
            root.pauseEnabled = false;
        case Enums.Statuses.NORMAL_END: //=== clicked somewhere
            var pausedTime = root.perDayPauseSeconds - root.timer.seconds;
            root.currentPauseTime = root.timer.seconds;
//            root.timer.seconds = root.currentPomodoroTime;//restore previous working time
            DB.finishCurrentRegistry(root.currentPauseRowID, pauseStatus);
    }
//    root.state = Enums.States.WORKING; Better maintain code consistency: state should be changed in root.handleStateFnish
    root.handleStateFinish(Enums.States.PAUSE,pauseStatus);
}

function startSummarizing() {
    root.state = Enums.States.SUMMARIZING;
    fullRepresentationPageStack.replace(root.summarizingPage);
    root.currentRowID = DB.start(Enums.RegistryTypes.SUMMARIZING, root.currentTodo);
    return true;
}

function endSummarizing(summarizingStatus) {
    root.calendarObject.saveCalendar();
    DB.finishCurrentRegistry(root.currentRowID, summarizingStatus);
    root.handleStateFinish(Enums.States.SUMMARIZING,summarizingStatus);
}

function startRinging() {
    root.state = Enums.States.RINGING;
    fullRepresentationPageStack.replace(root.ringingPage);
    root.currentRowID = DB.start(Enums.RegistryTypes.RINGING, root.currentTodo);
    return true;
}

function endRinging(ringingStatus) {
    DB.finishCurrentRegistry(root.currentRowID, ringingStatus);
    root.handleStateFinish(Enums.States.RINGING,ringingStatus);
}

function startShortBreak() {
    root.timer.totalSeconds = root.shortBreakLength;
    root.state = Enums.States.BREAK;
    fullRepresentationPageStack.replace(root.shortBreakPage);
    root.currentRowID = DB.start(Enums.RegistryTypes.SHORT_BREAK, root.currentTodo);
    return true;
}

function endShortBreak(breakStatus) {
    var statusType = breakStatus & Enums.Statuses.MASK;
    switch(statusType){
        case Enums.Statuses.NORMAL_END:
        case Enums.Statuses.CORRECT_END:
            root.todayStatistics.breakCount++;
            var restedTime = root.shortBreakLength - root.timer.seconds;
            console.log("rested time: ",restedTime);
            console.log("seconds: ",root.timer.seconds);
            root.todayStatistics.savedBreakTime += root.timer.seconds;
            root.todayStatistics.breakTime += restedTime;
            DB.finishCurrentRegistry(root.currentRowID,breakStatus);
    }
    root.handleStateFinish(Enums.States.SHORT_BREAK,breakStatus);
}

function startLongBreak() {
    root.timer.totalSeconds = root.longBreakLength;
    root.state = Enums.States.BREAK;
    fullRepresentationPageStack.replace(root.longBreakPage);
    root.currentRowID = DB.start(Enums.RegistryTypes.LONG_BREAK, root.currentTodo);
    return true;
}

function endLongBreak(breakStatus) {
    var type = statusType(breakStatus);
    switch(type){
        case Enums.Statuses.NORMAL_END:
        case Enums.Statuses.CORRECT_END:
            root.todayStatistics.breakCount++;
            var restedTime = root.longBreakLength - root.timer.seconds;
            root.todayStatistics.savedBreakTime += root.timer.seconds;
            root.todayStatistics.breakTime += restedTime;
            DB.finishCurrentRegistry(root.currentRowID,breakStatus);
    }

    root.handleStateFinish(Enums.States.LONG_BREAK,breakStatus);
}

//Manual handling function

//function handleMainActionButtonClick(){
//    if(fullRepresentationPageStack.currentPage.mainActionButtonClickHandler() === false)
//        switch(root.state){
//            case Enums.Enums.States.WORKING: // working -> paused
//                print("pre-playPause(): " + root.currentPauseTime);
//                if( ! startPause() ){
//                    displayError("Pause time for today exeeded!");
//                    plasmoid.fullRepresentationItem.pauseEnabled = false;
//                }
//            break;
//    //        case Enums.Enums.States.IDLE: // idle -> startPomo
//    //            if(root.manualMode)
//    //                startWorking();
//    //        break;
//    //        case Enums.Enums.States.PAUSE: // paused -> working
//    //            endPause(PauseStatus.RESUME);
//    //        break;
//    //        case Enums.Enums.States.BREAK: // break -> working
//    //            endBreak();
//    //        break;
//    //        case Enums.Enums.States.RINGING:
//    //            endRinging(); //Starts break
//    //        break;
//            case Enums.Enums.States.ALMOST_RINGING:
//                root.preventRing = true;
//        }
//}

//Utility functions

function enumsEquals(e1, e2){
    //Enums.WorkingStatus.DROP
    //Enums.WorkingStatus.PAUSE
    //0001001000000100 Working | PAUSE
    //0000000000100100 PAUSE
    //0001001000100000
    //0000000000000100
//    console.log("llamado enumsEquals("+e1+","+e2+")");
    var AND = e1 & e2;
//    console.log("AND: "+AND);
//    console.log("AND & e1: "+AND & e1);
//    console.log("AND & e2: "+AND & e2);
    if((e1 - AND) == 0)
        return true;
    if((e2 - AND) == 0)
        return true;
    return false;
}

function statusType(status){
    return Enums.Statuses.MASK & status;
}

function displayError(message){
    Dialogs.dialog("Alert.qml", message);
}

function setAction(action, actionName){
    plasmoid.removeAction(root.currentAction);
    root.currentAction = action;
    plasmoid.setAction(root.currentAction, actionName);
}

//Helper functions

function getSecondsElapsed(date, time){
    var now = new Date();
    var locale_correction = now.toString().replace(/.*GMT(.....).*/,"$1");
    var datetime = new Date(date + "T" + time + locale_correction);
    return Math.floor((now - datetime)/1000);
}

//DB information recovery

function saveStatistics(){
    DB.updateStatistics(root.todayStatistics)
}

function loadStatistics(){
    var row = DB.getStatisticsRow();
    if(row){
        root.todayStatistics.pauseTime = row.pauseTime;
        root.todayStatistics.breakTime = row.breakTime;
        root.todayStatistics.pomoTime = row.pomoTime;
        root.todayStatistics.savedBreakTime = row.savedBreakTime;
        root.todayStatistics.pauseCount = row.pauseCount;
        root.todayStatistics.pomoCount = row.pomoCount;
        root.todayStatistics.breakCount = row.breakCount;
    }else
        saveStatistics();
}

function restoreFromEventualCrash(){
    //Check if there is an unfinished registry entry
    var rows = DB.getUnfinishedRegistryRows();
    if(rows.length > 0){
        var uid = rows[0].todo_uid;
        var removeAll = false;//Decides if delete all this unfinished rows for greater good
        var todo = root.calendarObject.componentByUid(rows[0].todo_uid);
        if(todo)
            root.currentTodo = todo;
        else //UID from registry inexistant
            removeAll = true;
        for(var i in rows)
            if(rows[i].todo_uid !== uid)//Registry corruption
                removeAll = true;
        for(var j in rows){
            if(removeAll)
                DB.deleteRegistryRow(rows[j].id);
            else{
                var row = rows[j];
                var timeElpasedSinceStart = getSecondsElapsed(row.day, row.start_time);
                switch(row.type){ //completar root.current[Puase]RowID
                    case 0: //Was in Pomodoro before crash
                        if(timeElpasedSinceStart > root.pomodoroLength * 2)//Very long crash
                            DB.deleteRegistryRow(row.id); //Better dropping this very probably false long row
                        else if(timeElpasedSinceStart > root.pomodoroLength * 1.5)//Long crash
                            DB.finishCurrentRegistry(row.id, row.type, row.startTime, "+"+root.pomodoroLength+" minutes");
                        else if(timeElpasedSinceStart >= root.pomodoroLength)//Not so long crash
                            DB.finishCurrentRegistry(row.id);
                        else{//timeElpasedSinceStart < root.pomodoroLength
                            startWorking(root.pomodoroLength - timeElpasedSinceStart);
                        }
                    break;
//                    case 1: //Was in break before crash
//                        if(timeElpasedSinceStart > root.shortBreakLength)
//                            DB.finishCurrentRegistry(row.id);
//                        else{
//                            timer.seconds = root.shortBreakLength - timeElpasedSinceStart;
//                            root.state = "break";
//                        }
//                    break;
//                    case 2: //Was in pause before crash
//                        //TODO: put real values to this variables when statistical
//                        //      functions from DB are ready
//                        root.currentPauseTime = root.perDayPauseSeconds - timeElpasedSinceStart;
//                        root.currentPomodoroTime = root.pomodoroLength - timeElpasedSinceStart;
//                        root.currentPauseRowID = row.id;
//                        if(root.currentPauseTime > 0){
//                            timer.seconds = root.currentPauseTime;
//                            root.state = "pause";
//                        }else{
//                            if(root.currentPomodoroTime > 0)
//                                endPause();
//                            else{
//                                DB.finishCurrentRegistry(row.id);
//                                DB.finishCurrentRegistry(pomoRow.id);
//                            }
//                        }
                }
            }
        }
    }
    //TODO: This hotfix finishes row's times to when this executes, should delete rows if crashes
    //exceeds some time treshold
}

//Debug functions

function replacer(key, value) {
  if (value === null)
      return "null";
  if (typeof value === "object") {
    return "{" + Object.keys(value).join(", ") + "}";//"{}";//objKeys(value);
  }
  return value;
}

function objKeys(obj){
    var ownPNs = Object.getOwnPropertyNames(obj).sort();
    var keys = Object.keys(obj);
    var ret = "{ ";
    for(var i = 0, j = 0; i < keys.length; i++){
        while(ownPNs[i] !== keys[j])
            ret += keys[j++] + ", ";
        ret += '+' + keys[j++] + ", ";
    }
    return ret.replace(/, $/, " }");
}

function stringify(obj){
//    return objKeys(obj)//JSON.stringify(obj, replacer, 4);
    return JSON.stringify(obj, replacer, 4);
}

function debug(str, tty){
    tty = typeof tty !== "undefined" ? tty : true;
    if (tty){
        print(str);
        console.trace();
    }
//    if(plasmoid){
//        plasmoid.rootItem.debugOutput.text += str + "    ---- funcando con plasmoid.rootItem\n";
//    }else
    if(/org\.kde\.plasma\.debugger/.test(plasmoid.file('')))//this is the debugger
        root.debugOutput.text = str + "\n" + root.debugOutput.text;
}

