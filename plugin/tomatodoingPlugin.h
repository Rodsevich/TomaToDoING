#ifndef TOMATODOINGPLUGIN_H
#define TOMATODOINGLUGIN_H

#include <QQmlExtensionPlugin>
#include "calendarevent.h"
#include "calendartodo.h"
#include "tomatodoing.h"

class TomatodoingPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")
public:
    virtual void registerTypes(const char *uri);
};

#endif // TOMATODOINGPLUGIN_H
