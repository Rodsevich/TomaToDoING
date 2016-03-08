#ifndef TOMATODOING_H
#define TOMATODOING_H

#include <QObject>
#include <QFile>
#include <QFileSystemWatcher>
#include <QtCore/QDate>
#include <kcalcore/memorycalendar.h>
#include <kcalcore/filestorage.h>

Class Tomatodoing : Public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString uri READ uri WRITE setUri NOTIFY uriChanged)
    Q_PROPERTY(QDate date READ date WRITE setDate)
    Q_PROPERTY(QQmlListProperty<CalendarEvent> events READ events)
    Q_PROPERTY(QQmlListProperty<CalendarTodDo> todos READ todos)

public:

    QString uri();
    void setUri(QString& uri);

    QDate date();
    void setDate(QDate& date);

    QQmlListProperty<CalendarEvent> events();
    QQmlListProperty<CalendarToDo> todos();

public slots:
    void fileChangedSlot(QString file);

Q_SIGNALS:
    void fileChanged();
    void uriChanged();

private:
    QString _uri;
    QFileSystemWatcher _watcher;
    KCalCore::MemoryCalendar::Ptr _cal;
    KCalCore::FileStorage _store;
};

#endif //TOMATODOING_H
