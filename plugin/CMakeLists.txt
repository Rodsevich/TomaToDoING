add_definitions(-DTRANSLATION_DOMAIN="plasma_applet_org.kde.plasma.tomatodoing")

set(SRCS
	tomatodoingPlugin.cpp
	tomatodoing.cpp
)

add_library(tomatodoingplugin SHARED ${SRCS})

find_package(Qt5 COMPONENTS
	Quick
)
find_package(KF5 COMPONENTS
	CalendarCore
)

target_link_libraries(tomatodoingplugin
			Qt5::Quick
			KF5::CalendarCore
		     )

install(TARGETS tomatodoingplugin DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/private/tomatodoingplugin)
install(FILES qmldir DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/private/tomatodoingplugin)
