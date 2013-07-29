#include <QGraphicsObject>
#include <QImage>
#include <QFile>
#include <QPainter>
#include <QStyleOptionGraphicsItem>
#include <QDir>
#include <QDebug>
#include <QDateTime>
#include <QFileInfoList>
#include "imagesaver.h"

ImageSaver::ImageSaver(QObject *aParent) : QObject(aParent), mImagePath("")
{
    qDebug() << "ImageSaver::ImageSaver()" ;
    initMembers();
}

ImageSaver::~ImageSaver()
{
    qDebug() << "ImageSaver::~ImageSaver()" ;
}

void ImageSaver::saveImage(QGraphicsObject* aItem)
{
    if (!aItem) {
        qDebug() << "aItem is NULL";
        emit saveReturned(false);
        return;
    }

    QDateTime saveTime = QDateTime::currentDateTime();
    QString filePath = mImagePath + "/" + saveTime.toString("dd_MM_yyyy") + "_" +saveTime.toString("hh_mm_ss_zzz") + ".jpg";

    QImage img(aItem->boundingRect().size().toSize(), QImage::Format_RGB32);
    img.fill(QColor(255, 255, 255).rgb());
    QPainter painter(&img);
    QStyleOptionGraphicsItem styleOption;
    aItem->paint(&painter, &styleOption);

    emit saveReturned(img.save(filePath));
}

void ImageSaver::setImagePath(QString aPath)
{
    if(mImagePath != aPath)
    {
        mImagePath = aPath;
        emit imagePathChanged(mImagePath);
    }
}

QString ImageSaver::imagePath()
{
    return mImagePath;
}

void ImageSaver::initMembers()
{
    QFileInfoList foldList = QDir::drives();

    QString rootDriver = "C:/";

    QFileInfo tempInfo;

    foreach(tempInfo, foldList)
    {
        qDebug() << "tempInfo.absolutePath is : " << tempInfo.absolutePath();
        if(tempInfo.absolutePath() == "E:/")
        {
            rootDriver = "E:/";
            break;
        }
    }

    QString blogImgPath = rootDriver + "Twitter_Images";
    QDir blogImgDir(blogImgPath);

    if(!blogImgDir.exists())
    {
        blogImgDir.mkdir(blogImgPath);
    }

    mImagePath = blogImgPath;
}
