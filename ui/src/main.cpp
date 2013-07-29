#include <QApplication>
#include <QDeclarativeEngine>
#include <QtDeclarative>
#include <QTextCodec>
#include "applicationviewer.h"

#ifdef Q_OS_SYMBIAN
#include <aknappui.h>
#include <eikenv.h>
#include <eikbtgpc.h>
#endif

#include "httprequest.h"
#include "location.h"
#include "orientation.h"
#include "camera.h"
#include "debugUtil.h"
#include "imagesaver.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    INSTALL_MESSAGE_HANDLER;

    QTextCodec *codec = QTextCodec::codecForName("UTF-8");
    QTextCodec::setCodecForLocale(codec);
    QTextCodec::setCodecForCStrings(codec);
    QTextCodec::setCodecForTr(codec);

#if defined(Q_OS_WIN32)
    QNetworkProxyFactory::setUseSystemConfiguration(true);
#endif

    ApplicationViewer viewer;
    gUniqueNetwrkManager = viewer.engine()->networkAccessManager();

    qmlRegisterType<TwtLocation>("TwitterEngine", 1, 0, "TwtLocation");
    qmlRegisterType<HttpRequest>("TwitterEngine", 1, 0, "HttpRequest");
    qmlRegisterType<TwtCamera>("TwitterEngine", 1, 0, "TwtCamera");
    qmlRegisterType<TwtOrientation>("TwitterEngine", 1, 0, "TwtOrientation");
    qmlRegisterType<ImageSaver>("TwitterEngine", 1, 0, "ImageSaver");

    viewer.setSource(QUrl("qrc:/main.qml"));

#ifdef Q_OS_SYMBIAN
    if (iAvkonAppUi)
    {
        iAvkonAppUi->SetOrientationL(CAknAppUi::EAppUiOrientationPortrait);

        // Hide the CBA
        MEikAppUiFactory *factory = CEikonEnv::Static()->AppUiFactory();
        factory->CreateResourceIndependentFurnitureL(iAvkonAppUi);
        CEikButtonGroupContainer *cba = CEikButtonGroupContainer::NewL(CEikButtonGroupContainer::ECba,
                                                                       CEikButtonGroupContainer::EHorizontal,
                                                                       iAvkonAppUi, 0);
        CEikButtonGroupContainer *oldCba = factory->SwapButtonGroup(cba);
        cba->MakeVisible(EFalse);
    }
#endif

    QObject::connect(viewer.engine(), SIGNAL(quit()), &app, SLOT(quit()));

#ifdef Q_OS_SYMBIAN
    viewer.showMaximized();
#else
    viewer.showFullScreen();
#endif

    int ret = app.exec();
    UNSTALL_MESSAGE_HANDLER
    return ret;
}
