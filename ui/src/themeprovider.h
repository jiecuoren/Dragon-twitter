#ifndef THEMEPROVIDER_H
#define THEMEPROVIDER_H

#include <QDeclarativeImageProvider>

class ThemeProvider : public QDeclarativeImageProvider
{
public:
    ThemeProvider();
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize& requestedSize);
};

#endif // THEMEPROVIDER_H
