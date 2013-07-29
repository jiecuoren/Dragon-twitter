#include <QApplication>
#include <QImage>
#include <QImageReader>
#include <QFile>
#include <QtCore/qmath.h>
#include <QDebug>

#include "imagescaler.h"

const QString KTemporayImage = "/tweeties_tempfile.";
QString TwtImageScaler::mSuffix = "jpg";

TwtImageScaler::TwtImageScaler(QObject* parent) : QObject(parent)
{

}

QString TwtImageScaler::scaled(const QString& aFilePath, const qint64 aRequestedSize)
{
    QImage* originalImg = new QImage(aFilePath);
    mSuffix = aFilePath.section('.', -1);
    QString convertfile = aFilePath;
    // maybe load image failed for memory sake
    if (originalImg->isNull())
    {
        qDebug() << "TwtImageScaler::scaled img is null, open by scaled again";
        QImageReader reader(aFilePath);
        reader.setScaledSize(QSize(1024, 1024));
        bool reslt = reader.read(originalImg);
        if(!reslt)
        {
            qDebug() << "TwtImageScaler::scaled open img failed";
            return aFilePath;
        }
    }

    QSize oriImageSize = originalImg->size();
    qint64 filesize = originalImg->byteCount()/8;
    QFile originalFile(aFilePath);
    if (originalFile.open(QIODevice::ReadOnly))
    {
        filesize = originalFile.size();
        originalFile.close();
    }
    delete originalImg;

    qDebug() << "TwtImageScaler::scaled original file Size=" << filesize;
    QImage scaledImg;
    if (filesize > aRequestedSize)
    {
        qreal scaleScope = qSqrt(filesize/aRequestedSize);
        int shrinkWidth = oriImageSize.width() / scaleScope;
        int shrinkHeight = oriImageSize.height() / scaleScope;

        QImageReader scaleReader(aFilePath);
        scaleReader.setScaledSize(QSize(shrinkWidth, shrinkHeight));
        bool reslt = scaleReader.read(&scaledImg);
        if(!reslt)
        {
            qDebug() << "TwtImageScaler::scaled read img failed";
            return aFilePath;
        }
        qDebug()<< "after scale filesize" << scaledImg.size();
    }

    if (filesize > aRequestedSize)
    {
        QString fileName = qApp->applicationDirPath() + KTemporayImage + mSuffix;
        QFile file(fileName);
        if (!file.open(QIODevice::WriteOnly))
        {
            qDebug() << "open file failed";
        }
        else
        {
            if (scaledImg.save(&file))
            {
                convertfile = fileName;
                qDebug() << "icon.save(&file); " << file.size();
            }
            file.close();
        }
    }
    return convertfile;
}

void TwtImageScaler::removeTemporaryFile()
{
    QFile::remove(qApp->applicationDirPath() + KTemporayImage + mSuffix);
}
