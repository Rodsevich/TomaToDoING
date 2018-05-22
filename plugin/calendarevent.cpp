#include "calendarevent.h"

CalendarEvent::CalendarEvent(QObject *parent)
    : Incidence(parent){
    _object = new KCalCore::Event();
}

CalendarEvent::CalendarEvent(QObject *parent, FileCalendar *calendar, KCalCore::Event *event)
    : Incidence(parent, calendar){
    _object = event;
}

KCalCore::Event *CalendarEvent::get_object(){
    return this->_object;
}

CalendarEvent::~CalendarEvent(){
    delete get_object();
}

QDateTime CalendarEvent::startDateTime(){
    return get_object()->dtStart();
}

void CalendarEvent::setStartDateTime(QDateTime startDT){
//    KDateTime *KstartDT = new KDateTime(startDT);
    if( startDateTime() != startDT){
        get_object()->setDtStart(startDT);
        emit secondsDurationChanged();
        emit startDateTimeChanged();
    }
}

QDateTime CalendarEvent::endDateTime(){
    return get_object()->dtEnd();
}

void CalendarEvent::setEndDateTime(QDateTime endDT){
//    KDateTime *KendDT = new KDateTime(endDT);
    if( endDateTime() != endDT){
        get_object()->setDtEnd(endDT);
        emit secondsDurationChanged();
        emit endDateTimeChanged();
    }
}

int CalendarEvent::secondsDuration(){
    return get_object()->duration().asSeconds();
}
