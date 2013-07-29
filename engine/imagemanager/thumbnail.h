#ifndef TWTTHUMBNAIL_H
#define TWTTHUMBNAIL_H

#include <QDeclarativeImageProvider>

class TwtThumbnail : public QDeclarativeImageProvider
{
public:
    TwtThumbnail();
    QImage requestImage(const QString &id, QSize *size, const QSize& requestedSize);
};

#endif // TWTTHUMBNAIL_H
