TARGET = qmltwitter_20034cc4
TEMPLATE = app

QT += core network declarative webkit script
CONFIG += mobility

MOBILITY =  systeminfo \
            multimedia \
            messaging \
            location \
            gallery

include(engine/engine.pri)

INCLUDEPATH += ui/src
HEADERS += ui/src/themeprovider.h \
           ui/src/applicationviewer.h

SOURCES += ui/src/main.cpp \
           ui/src/themeprovider.cpp \
           ui/src/applicationviewer.cpp

RESOURCES += ui/resource.qrc

OTHER_FILES += ui/*.qml \
               ui/components/*.qml \
               ui/components/*.js \
               ui/views/*.qml \
               ui/javascript/*.js \
               ui/models/*.qml \
               ui/apis/*.qml \
	       ui/default/*.png \
               ui/components/keyboard/*.qml

DEFINES += LOG_ENABLED
#DEFINES += LOG_TO_FILE
#DEFINES += APP_LOG_ONLY

symbian {
        TARGET.UID3 = 0x20034cc4
        TARGET.CAPABILITY += LocalServices \
                             NetworkServices \
                             UserEnvironment \
                             ReadUserData \
                             WriteUserData \
                             ReadDeviceData \
                             WriteDeviceData \
                             SwEvent \
                             Location \
                             PowerMgmt \
                             SurroundingsDD \
                             ProtServ

        BLD_INF_RULES.prj_exports += \
            "engine/camera/ServiceHandler.lib       ../release/armv5/lib/ServiceHandler.lib" \
            "engine/camera/NewService{000a0000}.dso ../release/armv5/lib/NewService{000a0000}.dso" \
            "engine/camera/NewService{000a0000}.lib ../release/armv5/lib/NewService{000a0000}.lib" \
            "engine/camera/newservice.dso           ../release/armv5/lib/newservice.dso" \
            "engine/camera/NewService.lib           ../release/armv5/lib/NewService.lib"

        LIBS += -lcone -lavkon -leikcore -leikcoctl -lServiceHandler -lNewService -lbafl
        ICON = ui/default/icon_96.svg
        TARGET.EPOCHEAPSIZE = 0x80000 0x2000000  #32MB
        TARGET.EPOCSTACKSIZE = 0x10000
}




