#ifndef TWTIMAGESCALER_H
#define TWTIMAGESCALER_H

#include <QObject>

class TwtImageScaler : public QObject
{
    Q_OBJECT

public:
    explicit TwtImageScaler(QObject* parent = 0);
    static QString scaled(const QString& aFilePath, const qint64 aRequestedSize = 200*1024);
    static void removeTemporaryFile();

private:
    static QString mSuffix;
};

#endif // TWTTHUMBNAIL_H
