import QtQuick 2.0
import org.kde.plasma.private.filecalendarplugin 0.1

Item {

    property FileCalendar calendar
    property CalendarEvent _event

    /*
        Special vars:
         -%event_description%
         -%time_to_event_start%
         -%time_to_event_end%
    */
    property string aboutToStartNotification: "Automatic start of '%event_description%' in <b>%time_to_event_start%</b>"
    property string startedNotification: "Working on '%event_description%' for <b>%time_to_event_end%</b> more."
    property string _textoCache
    property int _tiempoCacheStart
    property int _tiempoCacheEnd

    NoticeText{
        id: cartelito
        width: parent.width
        height: parent.height
    }
    
    Timer{
        id: tim
        repeat: true
        interval: 1000
        triggeredOnStart: true
        onTriggered: actualizarDisplay()
    }

    function actualizarDisplay(){
        if(_tiempoCacheEnd > 0)
            cartelito.text = _textoCache.replace("%+%", tiempoImprimible(_tiempoCacheEnd--));
        if(_tiempoCacheStart > 0)
            cartelito.text = _textoCache.replace("%-%", tiempoImprimible(_tiempoCacheStart--));
    }

    function actualizarCache(){
        _textoCache = yaEmpezo(_event) ? startedNotification : aboutToStartNotification;
        _textoCache = _textoCache.replace(/%event_description%/g, _event.description);
        var s = _textoCache.replace(/%time_to_event_start%/g, "%-%");
        if(s != _textoCache){ //Hubo cambios
            _tiempoCacheStart = tiempoRestante(_event.startDateTime);
            _textoCache = s;
        }else
            _tiempoCacheStart = -1;
        s = _textoCache.replace(/%time_to_event_end%/g, "%+%");
        if(s != _textoCache){ //Hubo cambios
            _tiempoCacheEnd = tiempoRestante(_event.endDateTime);
            _textoCache = s;
        }else
            _tiempoCacheEnd = -1;
    }

    function actualizarEvento(){
        if(calendar.events.length >= 1){
            var eventito = calendar.events[0];
            for(var event in calendar.events){
                if(event.startDateTime < eventito.startDateTime)
                    eventito = event;
            }
            if(eventito != _event){
                _event = eventito;
                actualizarCache();
            }
        }
    }

    function tiempoImprimible(segundos){
        var d = new Date(0);
        d.setUTCSeconds(seconds);
        return d.toUTCString().match(/\d\d:\d\d:\d\d/)[0];
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
            name: "aboutToStart"
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
        }
    ]
}
