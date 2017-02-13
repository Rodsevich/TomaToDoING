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
    property int _segundosCacheStart
    property int _segundosCacheEnd

    property alias contador: tim
    property alias carte: cartelito

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
        console.log("Entre");
        if(_segundosCacheEnd > 0)
            cartelito.text = _textoCache.replace("%+%", tiempoImprimible(_segundosCacheEnd--));
        if(_segundosCacheStart > 0)
            cartelito.text = _textoCache.replace("%-%", tiempoImprimible(_segundosCacheStart--));
    }

    function actualizarCache(){
        _textoCache = yaEmpezo(_event) ? startedNotification : aboutToStartNotification;
        _textoCache = _textoCache.replace(/%event_description%/g, _event.description);
        var s = _textoCache.replace(/%time_to_event_start%/g, "%-%");
        if(s != _textoCache){ //Hubo cambios
            _segundosCacheStart = segundosRestantes(_event.startDateTime);
            _textoCache = s;
        }else
            _segundosCacheStart = -1;
        s = _textoCache.replace(/%time_to_event_end%/g, "%+%");
        if(s != _textoCache){ //Hubo cambios
            _segundosCacheEnd = segundosRestantes(_event.endDateTime);
            _textoCache = s;
        }else
            _segundosCacheEnd = -1;
    }

    function actualizarEvento(){
        if(calendar.events.length >= 1){
            var eventito = calendar.events[0];
            for(var event in calendar.events){
                if((event.startDateTime < Date.now() || event.endDateTime > Date.now())
                        && event.startDateTime < eventito.startDateTime)
                    eventito = event;
            }
            if(eventito != _event){
//                console.log("Entre");
                _event = eventito;
                actualizarCache();
                actualizarEstado();
                tim.start();
            }
        }
    }

    function actualizarEstado(){
        if(_event.startDateTime < Date.now)
            this.state = "Started";
        else
            this.state = "AboutToStart";
    }

    function tiempoImprimible(segundos){
        var d = new Date(0);
        d.setUTCSeconds(seconds);
        return d.toUTCString().match(/\d\d:\d\d:\d\d/)[0];
    }

    function yaEmpezo(evento){
        return Date.now() - evento.startDateTime < 0;
    }

    function segundosRestantes(dateTime){
        console.log((dateTime.getTime() - Date.now()) / 1000);
        return (dateTime.getTime() - Date.now)/1000;
    }

    Connections{
        target: calendar
        onEventsChanged: actualizarEvento()
    }

    Component.onCompleted: {
//        console.log("Entre");
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
        }
    ]
}
