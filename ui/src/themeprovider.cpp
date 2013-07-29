#include <QDebug>

#include "themeprovider.h"

ThemeProvider::ThemeProvider() : QDeclarativeImageProvider(QDeclarativeImageProvider::Pixmap)
{

}

QPixmap ThemeProvider::requestPixmap(const QString &id, QSize */*size*/, const QSize& /*requestedSize*/)
{
    QPixmap pixmap;
    QStringList strList = id.split("/");
    QString themeName = strList.at(0);

    if (themeName == "default")
    {
        QString name = ":/" + id;
        bool ret = pixmap.load(name);
        if (!ret)
        {
            qDebug() << "load image file " << id << " failed, check the existence!";
        }
    }

    return pixmap;
}
