import QtQuick 2.0
import org.kde.plasma.private.filecalendarplugin 0.1

Item {

    property FileCalendar calendar

    /*
        Special vars:
         -%event_description%
         -%event_summary%
         -%time_to_event_start%
         -%time_to_event_end%
    */
    //Setters
    property string aboutToStartNotification: "Automatic start of '%event_summary%' in <b>%time_to_event_start%</b>"
    property string startedNotification: "Working on '%event_summary%' for <b>%time_to_event_end%</b> more."
    property string noEventsNotification: "No events to auto-start"

    //Getters
    property CalendarEvent forthcomingEvent
    property bool inEventRunning: false

    //Internal vars
    property string _textoCache
    property int _segundosCacheStart
    property int _segundosCacheEnd
    property bool _repaintNeeded: false

    signal startedEvent(CalendarEvent event)
    signal endedEvent(CalendarEvent event)
    signal changedEvent(CalendarEvent event)

//    property alias contador: tim
//    property alias nt: cartelito

    implicitHeight: cartelito.implicitHeight
    implicitWidth: cartelito.implicitWidth

    NoticeText{
        id: cartelito
        width: parent.width
        height: parent.height
        text: "Events autoStarter"
    }
    
    Timer{
        id: tim
        repeat: true
        interval: 1000
        triggeredOnStart: true
        onTriggered: actualizarDisplay()
    }

    function actualizarDisplay(force){
        force = typeof force !== 'undefined' ? force : false;
        var changed = false;
//        var out = (force) ? " (f)." : ".";
//        root.debug("Display: " + _segundosCacheStart + " <-> " + _segundosCacheEnd + out);
        var buff = _textoCache;
        if(_segundosCacheEnd > 0){
            if(force) _segundosCacheEnd++;
            buff = buff.replace("%+%", segundosImprimibles(_segundosCacheEnd--));
            changed = true;
        }
        if(_segundosCacheStart > 0){
            if(force) _segundosCacheStart++;
            buff = buff.replace("%-%", segundosImprimibles(_segundosCacheStart--));
            changed = true;
        }
        if(_repaintNeeded || force){
            _repaintNeeded = false;
            changed = true;
        }
        if(changed)
            cartelito.text = buff;
        else
            actualizarEstado();
    }

    function actualizarCache(){
        if(forthcomingEvent == null || yaTermino(forthcomingEvent)){
            _textoCache = noEventsNotification;
        }
        else{
            _textoCache = yaEmpezo(forthcomingEvent) ? startedNotification : aboutToStartNotification;
            _textoCache = _textoCache.replace(/%event_description%/g, forthcomingEvent.description);
            _textoCache = _textoCache.replace(/%event_summary%/g, forthcomingEvent.summary);

            var s = _textoCache.replace(/%time_to_event_start%/g, "%-%");
            if(s != _textoCache){ //Hubo cambios
                _segundosCacheStart = segundosRestantes(forthcomingEvent.startDateTime);
                _textoCache = s;
            }else
                _segundosCacheStart = -1;

            s = _textoCache.replace(/%time_to_event_end%/g, "%+%");
            if(s != _textoCache){ //Hubo cambios
                _segundosCacheEnd = segundosRestantes(forthcomingEvent.endDateTime);
                _textoCache = s;
            }else
                _segundosCacheEnd = -1;
        }
        actualizarDisplay(true);
    }

    function actualizarEvento(){
//        root.debug("actEvt: " + calendar.events.length);
        if(calendar.events.length >= 1){
            var eventito = {"summary": "borrame rapido", "startDateTime" : new Date(9999,11,30,23,59,59)};
            var now = timeStr(new Date());
            for(var i in calendar.events){
                var event = calendar.events[i],
                    start = timeStr(event.startDateTime),
                    end = timeStr(event.endDateTime);
//                root.debug("(" + now + ") " + start + " - " + end + ". [" + (start > now) + " || " + (end > now) + "] && " + (start < timeStr(eventito.startDateTime)) + ".");
                if((start > now || end > now) && (start < timeStr(eventito.startDateTime))){
//                    root.debug("<font color='green'>" + event.summary + "</font>");
                    eventito = event;
                }
//                else
//                    root.debug("<font color='red'>" + event.summary + "</font>");
            }
            if(eventito != forthcomingEvent){
                forthcomingEvent = eventito;
                changedEvent(forthcomingEvent);
                actualizarEstado();
            }
        }else{
            forthcomingEvent = null;
            actualizarCache();
        }
    }

    function actualizarEstado(){
        if(yaTermino(forthcomingEvent)){
            tim.stop();
            endedEvent(forthcomingEvent);
            inEventRunning = false;
            this.state = "NoEvents";
            actualizarCache();
            actualizarEvento();
        }else{
            if(yaEmpezo(forthcomingEvent)){
                this.state = "Started";
                inEventRunning = true;
                startedEvent(forthcomingEvent);
            }else
                this.state = "AboutToStart";
            actualizarCache();
            tim.start();
        }
    }

    function timeStr(dateTime){
        return dateTime.toTimeString().slice(0,8);
    }

    function segundosImprimibles(seconds){
        var d = new Date(0);
        d.setUTCSeconds(seconds);
        return d.toUTCString().slice(12,21);
//        return d.toUTCString().match(/\d\d:\d\d:\d\d/)[0];
    }

    function yaEmpezo(evento){
        var tiempo = timeStr(evento.startDateTime);
        return timeStr(new Date()) >= tiempo;
    }

    function yaTermino(evento){
        var tiempo = timeStr(evento.endDateTime);
        return timeStr(new Date()) >= tiempo;
    }

    function segundosRestantes(dateTime){
        var now = new Date();
        dateTime.setYear(now.getFullYear());
        dateTime.setMonth(now.getMonth());
        dateTime.setDate(now.getDate());
        var q = Math.ceil((dateTime.getTime() - Date.now())/1000);
        return q;
    }

    Connections{
        target: calendar
        onEventsChanged: actualizarEvento()
    }

    Component.onCompleted: {
        actualizarEvento();
    }

    states: [
        State {
            name: "AboutToStart"
            PropertyChanges {
                target: cartelito
                backgroundColor: "darkred"
                textColor: "white"
            }
        },
        State {
            name: "Started"
            PropertyChanges {
                target: cartelito
                backgroundColor: "darkgreen"
                textColor: "#EDE"
            }
        },
        State {
            name: "NoEvents"
            PropertyChanges {
                target: cartelito
                backgroundColor: "#333"
                textColor: "#EEE"
            }
        }
    ]
}
