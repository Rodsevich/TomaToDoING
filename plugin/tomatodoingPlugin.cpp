#include <QtQml>

void TomatodoingPlugin::registerTypes (const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.plasma.private.tomatodoingplugin"));
    qmlRegisterType<Tomatodoing>(uri, 0, 1, "TomaToDoING");
    qmlRegisterType<CalendarToDo>(uri, 0, 1, "CalendarToDo");
    qmlRegisterType<CalendarEvent>(uri, 0, 1, "CalendarEvent");
}
