INCLUDEPATH += engine/location \
               engine/http \
               engine/camera \
               engine/imagemanager \
               engine/debugUtil \
               engine/imagesaver

HEADERS += engine/location/location.h \
           engine/http/httprequest.h \
           engine/camera/camera.h \
           engine/camera/orientation.h \
           engine/debugUtil/debugUtil.h \
           engine/imagemanager/thumbnail.h \
           engine/imagesaver/imagesaver.h \
           engine/imagemanager/imagescaler.h


SOURCES += engine/location/location.cpp \
           engine/http/httprequest.cpp \
           engine/camera/camera.cpp \
           engine/camera/orientation.cpp \
           engine/debugUtil/debugUtil.cpp \
           engine/imagemanager/thumbnail.cpp \
           engine/imagesaver/imagesaver.cpp \
           engine/imagemanager/imagescaler.cpp

