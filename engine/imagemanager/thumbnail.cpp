#include <QImageReader>

#include "thumbnail.h"

TwtThumbnail::TwtThumbnail() : QDeclarativeImageProvider(QDeclarativeImageProvider::Image)
{

}

QImage TwtThumbnail::requestImage(const QString &id, QSize */*aSize*/, const QSize& reqSize)
{
    QImageReader reader(id);
    reader.setQuality(25);
    //default size is 120*120, you can set size by set Image.sourceSize value
    QSize requestedSize(120, 120);
    if(reqSize.width() > 0 && reqSize.height() > 0)
    {
        requestedSize = reqSize;
    }

    if (reader.supportsOption(QImageIOHandler::Size))
    {
        QSize size = reader.size();
        if (!reader.supportsOption(QImageIOHandler::ScaledSize)
             && (size.width() > 1280 || size.height() > 1280))
        {
            return QImage();
        }

        if (size.width() > requestedSize.width() || size.height() > requestedSize.height())
        {
            size.scale(requestedSize, Qt::KeepAspectRatio);
        }
        reader.setScaledSize(size);
    }
    else
    {
        reader.setScaledSize(requestedSize);
    }
    return reader.read();
}
