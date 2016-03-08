#include "tomatodoing.h"

class Tomatodoing : QObject{
    QObject::connect(&this->_watcher, SIGNAL(fileChanged(QString)), this, SLOT(fileChangedSlot(QString)));
    _cal(new KCalCore::MemoryCalendar(KDateTime::UTC))
};

Tomatodoing::~Tomatodoing(){

}

void Tomatodoing::setUri(QString &uri){
    if (uri != _uri){
	_watcher.removePath(_uri);
	_watcher.addPath(uri);
	_uri = uri;
	emit uriChanged();
    }
}
