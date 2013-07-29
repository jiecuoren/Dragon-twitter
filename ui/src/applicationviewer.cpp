#include <QDeclarativeEngine>
#include <QDeclarativeContext>
#include <QLocale>
#include <QResizeEvent>

#include "applicationviewer.h"
#include "themeprovider.h"
#include "thumbnail.h"

ApplicationViewer::ApplicationViewer() : mSetSizeDone(false)
{
    setAttribute(Qt::WA_OpaquePaintEvent);
    setAttribute(Qt::WA_NoSystemBackground);
    viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewport()->setAttribute(Qt::WA_NoSystemBackground);

    engine()->addImageProvider("theme", new ThemeProvider);
    engine()->addImageProvider("thumbnail", new TwtThumbnail);
    rootContext()->setContextProperty("declarativeView", this);

    QString language =  QLocale::system().name();
    rootContext()->setContextProperty("languageIsEn", language.startsWith("en", Qt::CaseInsensitive));
}

void ApplicationViewer::resizeEvent(QResizeEvent *event)
{
    QDeclarativeView::resizeEvent(event);
    if(!mSetSizeDone)
    {
        QObject *mainQml = (QObject*)rootObject();

        int width = event->size().width();
        int height = event->size().height();
        mainQml->setProperty("width", width);
        mainQml->setProperty("height", height);
        setSceneRect(0, 0, width, height);
        mSetSizeDone = true;
    }
}
