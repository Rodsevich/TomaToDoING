        import QtQuick 2.5
    import QtMultimedia 5.5
    import QtQuick.Layouts 1.2
    import org.kde.plasma.plasmoid 2.0
    import org.kde.plasma.components 2.0 //as PlasmaComponents
    import org.kde.plasma.core 2.0 as PlasmaCore
    import org.kde.kquickcontrolsaddons 2.0 as QtExtra
    import org.kde.plasma.private.filecalendarplugin 0.1
    
    import "../code/dialogs.js" as Dialogs
    import "../code/logic.js" as Logic
    import "../code/enums.js" as Enums
    import "../code/localStorage.js" as DB
    
    import "Components" as Components
    import "Pages" as Pages
    
    Item {
        id: root
    
        property alias main: root
    
        Plasmoid.compactRepresentation: TrayRepresentation { }
        Plasmoid.fullRepresentation: FullRepresentation { }
        Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    
        Plasmoid.switchWidth: Layout.minimumWidth
        Plasmoid.switchHeight: Layout.minimumHeight
    
        Plasmoid.toolTipMainText: "TomaToDoING"
        Plasmoid.toolTipSubText:  "Your essential tool for getting things done!"
        Plasmoid.toolTipTextFormat: Text.StyledText
    
        width: units.gridUnit * 4
        height: units.gridUnit * 10
    //    Layout.minimumWidth: fullRepresentation.Layout.minimumWidth + 8
    //    Layout.minimumHeight: fullRepresentation.Layout.minimumHeight + 8
    
    
        property bool test: false
        //Configuration vars
        //times should be in seconds
        property string calendarLocation: "/home/nico/.local/share/apps/korganizer/std.ics"
        property int pomodoroLength: test ? 6 : plasmoid.configuration.pomodoroLength * 60
        property int shortBreakLength: test ? 4 : plasmoid.configuration.shortBreakLength * 60
        property int longBreakLength: test ? 7 : plasmoid.configuration.longBreakLength * 60
        property int perDayPauseSeconds: test ? 4 : plasmoid.configuration.perDayPauseTime * 60
        property int pomodorosPerLongBreak: test ? 2 : plasmoid.configuration.pomodorosPerLongBreak
        property bool warningBeforeRing: plasmoid.configuration.warningBeforeRing
        property int secondsRingWarning: test ? 3 : plasmoid.configuration.secondsWarningBeforeRing
        property int maxIdleMinutes: test ? 1 : plasmoid.configuration.maxIdleMinutes
        property bool maxIdleTimeMode: false // plasmoid.configuration.maxIdleTimeMode
        property bool manualMode: plasmoid.configuration.manualMode
        property int tickingVolume: plasmoid.configuration.tickingVolume
        property int pomodorosGoal: 11
        property int todayBreakTimeSaved: 0
        property bool infiniteRinging: plasmoid.configuration.infiniteRinging
        property int ringTime: plasmoid.configuration.ringTime

    
        //Internal vars
        property QtObject currentTodo: root.dummyTodo
        property bool onWorkingEvent: false
        property bool inPomodoro: false
        property bool inBreak: false
        property bool inPause: false
        property bool preventRing: false
        property int currentRowID: -1;
        property int currentPauseRowID: -1;
        property int currentPauseTime: -1;
        property int currentPomodoroTime: -1;
        property bool pauseEnabled: true;
        property var todayStatistics: {
            "pomoTime" : 0,
            "pauseTime" : 0,
            "breakTime" : 0,
            "pomoCount" : 0,
            "pauseCount" : 0,
            "breakCount" : 0,
            "savedBreakTime" : 0
        }
        property string currentAction: "startPomo"
    
        //Actual timer. This will store the remaining seconds, total seconds and will return a timeout in the end and alert in near-end.
        property QtObject timer: Components.TomatoidTimer {
            id: timer
            totalSeconds: pomodoroLength
            secondsAlertBeforeTimeout: secondsRingWarning
    
    //        onTick: Logic.timerTick()
    //        onTimeout: Logic.timerTimeout()
    //        onAlertBeforeTimeout: Logic.timerAlertBeforeTimeout()
        }
    
        // When called from extern JS file, if "root.XXXSound" doesn't exists
        // they can be called with "root.resources[X].play()"
        property QtObject ringSound: SoundEffect { //Resource nº 0
            source: "../data/ring-play.wav"
            loops: SoundEffect.Infinite
            onPlayingChanged: !playing ? ringEndSound.play() : null
            volume: 1
        }
    
        property QtObject ringEndSound: SoundEffect { //Resource nº 1
            source: "../data/ring-end.wav"
        }
    
        property QtObject notificationSound: SoundEffect { //Resource nº 2
            source: plasmoid.file("data", "notification.wav")
        }
    
        property QtObject tickingSound: SoundEffect { //Resource nº 3
            source: plasmoid.file("data", "tomatoid-ticking.wav")
            volume: tickingVolume / 100 //volume from 0.1 to 1.0
        }
    
        property QtObject pauseSound: SoundEffect { //Resource nº 4
            source: "../data/swirl.wav"
        }
    
        property QtObject knockSound: SoundEffect { //Resource nº 5
            source: "../data/Knock.wav"
        }

        property QtObject sirenSound: SoundEffect { //Resource nº 6
            source: "../data/siren_noise.wav"
            loops: SoundEffect.Infinite
            volume: plasmoid.expanded ? 0.1 : 1.0
        }
    
        property QtObject calendarObject: FileCalendar{
            id: calendarObject
            uri: calendarLocation
        }
    
        property Item dummyTodo: Item{
            property bool completed: true
            property string uid: "dummy-to-do"
            property string summary: "dummy Todo"
            property string description: "This is a container to express a dummy Todo that doesn't breaks the program"
            property int percentCompleted: 0
        }
    
        //Pages
        property QtObject idlePage: Component{
            Pages.IdlePage{}
        }
        property QtObject pausePage: Component{
            Pages.PausePage{}
        }
        property QtObject workingPage: Component{
            Pages.WorkingPage{}
        }
        property QtObject ringingPage: Component{
            Pages.RingingPage{}
        }
        property QtObject longBreakPage: Component{
            Pages.LongBreakPage{}
        }
        property QtObject shortBreakPage: Component{
            Pages.ShortBreakPage{}
        }
        property QtObject summarizingPage: Component{
            Pages.SummarizingPage{}
        }
    

        //Items that must be created on the startup of the plasmoid

        property Item autostarterUI: Components.CalendarEventUI{
            id: autostarterUI
            calendar: calendarObject
//            anchors.top: parent.top
//            anchors.left: parent.left
//            anchors.right: parent.right

            onStartedEvent: stack.currentPage.signalize("eventAutoStart", forthcomingEvent)
        }

//        property Item stack
        //Page's container (stack)
        property Item stack: PageStack {
            id: stack
//            anchors.fill: plasmoid.fullRepresentationItem
            z: -99
            initialPage: root.idlePage
        }
    
        function handleStateFinish(stateName, finishStatus){
            DB.updateStatistics(todayStatistics);
            switch(stateName){
                case Enums.States.IDLE: // idle -> startPomo
                    Logic.startWorking();
                break;
                case Enums.States.WORKING:
                    if(Logic.enumsEquals(finishStatus, Enums.WorkingStatus.DROP)){
                        Logic.startIdle();
                    }else if(Logic.enumsEquals(finishStatus, Enums.WorkingStatus.PAUSE)){
                        Logic.startPause();
                    }else{
                        if(currentTodo === dummyTodo){
                            if(todayStatistics.pomoCount % root.pomodorosPerLongBreak === 0)
                                Logic.startLongBreak();
                            else
                                Logic.startShortBreak();
                        }else{
                            if(root.preventRing){
                                root.preventRing = false;
                                Logic.startSummarizing();
                            }else
                                Logic.startRinging();
                        }
                    }
                break;
                case Enums.States.PAUSE: // paused -> working
                    Logic.startWorking(root.currentPomodoroTime);
                break;
                case Enums.States.SUMMARIZING: // summarizing -> break
                    if(Logic.enumsEquals(Enums.SummarizingStatus.SKIP_BREAK, finishStatus)){
                        if(currentTodo.completed)
                            Logic.startIdle();
                        else
                            Logic.startWorking();
                    }else{
                        if(todayStatistics.pomoCount % root.pomodorosPerLongBreak === 0)
                            Logic.startLongBreak();
                        else
                            Logic.startShortBreak();
                    }
                break;
                case Enums.States.SHORT_BREAK: // break -> working
                case Enums.States.LONG_BREAK:
                    if( currentTodo.completed){
                        Logic.startIdle();
                    }else
                        Logic.startWorking();
                break;
                case Enums.States.RINGING:
                    Logic.startSummarizing();
                break;
                case Enums.States.ALMOST_RINGING://Probably never executed
                    root.preventRing = true;
            }
        }
    
        states: [
            //The code that appears here should only modify plasmoid's inherent properties only
            State {
                name: Enums.States.IDLE
                StateChangeScript {
                    script: {
                        plasmoid.toolTipMainText = "TomaToDoING";
                        plasmoid.toolTipSubText = "No plans for working right now";
                        Logic.setAction("startPomo", i18n("Start Pomodoro"));
                    }
                }
    
                PropertyChanges {
                    target: timer
                    running: false
                }
            },
            State {
                name: Enums.States.WORKING
    
                StateChangeScript {
                    script: {
                        plasmoid.toolTipMainText = "TomaToDoING ( " + todayStatistics.pomoCount + " / " + pomodorosGoal + " )";
                        plasmoid.toolTipSubText = "Working on: " + currentTodo.summary;
                        Logic.setAction("pausePomo", i18n("Pause Pomodoro"));
                    }
                }
    
                PropertyChanges {
                    target: root
                    inPomodoro: true
                }
                PropertyChanges {
                    target: timer
                    running: true
                }
            },
            State {
                name: Enums.States.PAUSE
    
                StateChangeScript {
                    script: {
                        Logic.setAction("restorePomo", i18n("Restore Pomodoro"));
                    }
                }
    
                PropertyChanges {
                    target: root
                    inPause: true
                }
                PropertyChanges {
                    target: timer
                    running: true
                }
            },
            State {
                name: Enums.States.BREAK
    
                StateChangeScript {
                    script: {
                        plasmoid.toolTipMainText = "TomaToDoING ( " + todayStatistics.pomoCount + " / " + pomodorosGoal + " )";
                        plasmoid.toolTipSubText = "Resting from: " + currentTodo.summary;
                        Logic.setAction("dropBreak", i18n("Drop Break"));
                    }
                }
                PropertyChanges {
                    target: root
                    inBreak: true
                }
                PropertyChanges {
                    target: timer
                    running: true
                }
            },
            State {
                name: Enums.States.SUMMARIZING
            },
            State {
                name: Enums.States.ALMOST_RINGING
                extend: Enums.States.WORKING
            },
            State {
                name: Enums.States.RINGING
                PropertyChanges {
                    target: timer
                    running: false
                }
            }
        ]
    
        Component.onCompleted: {
            Logic.root = root;
            Logic.plasmoid = plasmoid;
            state = Enums.States.IDLE;
            Logic.loadStatistics();
            Logic.restoreFromEventualCrash();
            Logic.fullRepresentationPageStack = stack;
            plasmoid.setActionSeparator("separator0");
        }

//        function setFullRepresentationPageStack(stack){
//            Logic.fullRepresentationPageStack = stack;
//        }
    
        function actionTriggered(actionName) {
            switch(actionName){
                case "restorePomo":
                    Logic.endPause();
                break;
                case "dropBreak":
                    Logic.endBreak();
                break;
                case "startPomo":
                    if(currentTodo !== null)
                        Logic.startWorking();
                break;
                case "pausePomo":
                    if( ! Logic.startPause())
                        plasmoid.removeAction(root.currentAction);
            }
        }
    
    //    Connections {
    //        target: plasmoid;
    //        onPopupEvent: {
    //            FullRepresentation.focus = true;
    //        }
    //    }
    
    }
    
    // Debug JS plasmoid objectroot.
    //console.log(Object.getOwnPropertyNames(plasmoid));
    //console.log(Object.getOwnPropertyNames(plasmoid.fullRepresentation));
    //console.log(Object.getOwnPropertyNames(plasmoid.fullRepresentationItem));
    
