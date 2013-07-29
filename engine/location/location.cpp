#include <QApplication>
#include <QFile>
#include <QImage>
#include <QDir>
#include <QTimer>
#include <QUrl>
#include <QNetworkConfigurationManager>
#include <QNetworkDiskCache>
#include <QDesktopServices>
#include <QtCore/qmath.h>

#include <qnmeapositioninfosource.h>
#include <qgeopositioninfosource.h>
#include <qgeopositioninfo.h>

#include "location.h"

const QString KCityTag = "<LocalityName>";
const QString KDistrictTag = "<DependentLocalityName>";
const QString KThoroughfareTag = "<ThoroughfareName>";
const QString KAddressTag = "<address>";
const QString KFormattedAddressTag = "<formatted_address>";
const int KGeoRequestTimeOut = 30 * 1000; // 30 s

extern QNetworkAccessManager* gUniqueNetwrkManager;

int long2tilex(double lon, int z)
{
    return (int)(qFloor((lon + 180.0) / 360.0 * qPow(2.0, z)));
}

int lat2tiley(double lat, int z)
{
    return (int)(qFloor((1.0 - qLn( qTan(lat * M_PI/180.0) + 1.0 / qCos(lat * M_PI/180.0)) / M_PI) / 2.0 * qPow(2.0, z)));
}

TwtLocation::TwtLocation(QObject* parent) :
                     QObject(parent), mHttpReply(NULL)
{
    QTimer::singleShot(0, this, SLOT(delayedInit()));
}

TwtLocation::~TwtLocation()
{
    if(mLocation)
    {
        mLocation->stopUpdates();
    }

    if (mRequestTimer->isActive())
    {
        mRequestTimer->stop();
    }

    mSession->close();
}

void TwtLocation::start(bool downMap)
{
    if (!mLocation)
    {
        // QGeoPositionInfoSource
        mLocation = QGeoPositionInfoSource::createDefaultSource(this);

        if (!mLocation)
        {
            QNmeaPositionInfoSource *nmeaLocation =
            new QNmeaPositionInfoSource(QNmeaPositionInfoSource::SimulationMode, this);
            QFile *logFile = new QFile(QApplication::applicationDirPath() + QDir::separator()
                                       + "nmealog.txt", this);
            qDebug() << "QNmeaPositionInfoSource " << QApplication::applicationDirPath();
            nmeaLocation->setDevice(logFile);
            mLocation = nmeaLocation;
        }
    }

    if (!mLocation)
    {
        qDebug() << "QGeoPositionInfoSource::create failed";
        emit localDone(1000.0, 1000.0, "Unknown Place");
        return;
    }

    mDownloadMyMap = downMap;
    // Listen gps position changes
    connect(mLocation, SIGNAL(positionUpdated(QGeoPositionInfo)),
            this, SLOT(positionUpdated(QGeoPositionInfo)));
    connect(mLocation, SIGNAL(updateTimeout()), this,
            SLOT(updateTimeout()));

    // Start listening GPS position updates
    mLocation->requestUpdate(KGeoRequestTimeOut);
}

void TwtLocation::downloadMap(double longitude, double latitude, int zoom)
{
    cancelHttpRequest(mHttpReply);
    int xValue = long2tilex(longitude, zoom);
    int yValue = lat2tiley(latitude, zoom);
    QString path = "http://tile.openstreetmap.org/%1/%2/%3.png";
    QUrl url = QUrl(path.arg(zoom).arg(xValue).arg(yValue));
    mHttpReply = gUniqueNetwrkManager->get(QNetworkRequest(url));
    connect(mHttpReply, SIGNAL(finished()), this, SLOT(handleSlippymapData()));
    mRequestTimer->start();
}

void TwtLocation::cancelHttpRequest(QNetworkReply* reply)
{
    if(NULL != reply)
    {
        //can't call "reply->abort()" directly, consider finished request.
        reply->isFinished() ? reply->close():reply->abort();
        reply->deleteLater();
        reply = NULL;
    }
}

void TwtLocation::positionUpdated(const QGeoPositionInfo &gpsPos)
{
    qDebug() << "TwtLocation::positionUpdated";
    if (gpsPos.isValid())
    {
        QGeoCoordinate coord = gpsPos.coordinate();
        qDebug() << QString::number(mLatitude) << " and long:" << QString::number(mLongitude);
        if (mLongitude != coord.longitude() || mLatitude != coord.latitude())
        {
            requestTownName(coord.longitude(), coord.latitude());
        }
        else
        {
            emit localDone(mLatitude, mLongitude, mTownName);
        }
        mLocation->stopUpdates();
    }
    else
    {
        emit localDone(1000.0, 1000.0, "Unknown Place");
    }
}

void TwtLocation::updateTimeout()
{
    qDebug() << "TwtLocation::updateTimeout";
    mLocation->stopUpdates();
    mDownloadMyMap = false;
    emit localDone(1000.0, 1000.0, "Unknown Place");
}

void TwtLocation::onRequestTimeout()
{
    qDebug() << "TwtLocation::onRequestTimeout";
    if((NULL != mHttpReply) && (mHttpReply->isOpen()))
    {
        // this will in turn emit QNetworkReply::error(QNetworkReply::OperationCanceledError)
        mHttpReply->close();
    }
}

void TwtLocation::delayedInit()
{
    qDebug() << "TwtLocation::delayedInit";
    QNetworkConfigurationManager manager;
    const bool canStartIAP = (manager.capabilities()
                            & QNetworkConfigurationManager::CanStartAndStopInterfaces);
    // Is there default access point, use it
    QNetworkConfiguration cfg = manager.defaultConfiguration();
    if (!cfg.isValid() || (!canStartIAP && cfg.state() != QNetworkConfiguration::Active))
    {
        qDebug() << "Not access point valid";
        return;
    }
    mSession = new QNetworkSession(cfg, this);
    connect(mSession, SIGNAL(opened()), this, SLOT(networkSessionOpened()));
    mSession->open();

    mRequestTimer = new QTimer(this);
    mRequestTimer->setSingleShot(true);
    mRequestTimer->setInterval(KGeoRequestTimeOut);
    connect(mRequestTimer, SIGNAL(timeout()), this, SLOT(onRequestTimeout()));
}

void TwtLocation::networkSessionOpened()
{
    qDebug() << "TwtLocation::networkSessionOpened";
    QNetworkDiskCache *cache = new QNetworkDiskCache;
    cache->setCacheDirectory(QDesktopServices::storageLocation(QDesktopServices::CacheLocation));
    gUniqueNetwrkManager->setCache(cache);
}

void TwtLocation::cancelOperation()
{
    if(mRequestTimer->isActive())
    {
        mRequestTimer->stop();
    }

    if(mLocation)
    {
        mLocation->stopUpdates();
    }
    onRequestTimeout();
}

void TwtLocation::requestTownName(double longitude, double latitude)
{
    mLongitude = longitude;
    mLatitude = latitude;

    QString longitudeStr;
    longitudeStr.setNum(longitude);
    QString latitudeStr;
    latitudeStr.setNum(latitude);

    QUrl url("http://maps.google.com/maps/geo");
    url.addEncodedQueryItem("q", QUrl::toPercentEncoding(latitudeStr + "," + longitudeStr));
    url.addEncodedQueryItem("output", QUrl::toPercentEncoding("xml"));

    cancelHttpRequest(mHttpReply);
    mHttpReply = gUniqueNetwrkManager->get(QNetworkRequest(url));
    connect(mHttpReply, SIGNAL(finished()), this, SLOT(handleTownNameData()));
    mRequestTimer->start();
}

void TwtLocation::handleTownNameData()
{
    qDebug() << "TwtLocation::handleTownNameData()";
    qDebug() << mHttpReply->error();

    if(mRequestTimer->isActive())
    {
        mRequestTimer->stop();
    }

    disconnect(mHttpReply, SIGNAL(finished()), this, SLOT(handleTownNameData()));

    QNetworkReply::NetworkError replyError = mHttpReply->error();
    if(QNetworkReply::NoError == replyError)
    {
        QString data = QString::fromUtf8(mHttpReply->readAll());
        int start, end;
        if (data.contains(KCityTag, Qt::CaseInsensitive))
        {
            start = data.indexOf(KCityTag);
            end = data.indexOf("</LocalityName>", start);
            mTownName = data.mid(start + KCityTag.length(), end - start - KCityTag.length());//北京市
            if (data.contains(KDistrictTag, Qt::CaseInsensitive))
            {
                //disctrict
                mTownName += ' ';
                start = data.indexOf(KDistrictTag);
                end = data.indexOf("</DependentLocalityName>", start);
                mTownName += data.mid(start + KDistrictTag.length(), end - start - KDistrictTag.length());//东城区

                //details position
                mTownName += ' ';
                start = data.indexOf(KThoroughfareTag);
                end = data.indexOf("</ThoroughfareName>", start);
                mTownName += data.mid(start + KThoroughfareTag.length(), end - start - KThoroughfareTag.length()); //和平里西街1号
            }
        }
        else if(data.contains(KAddressTag, Qt::CaseInsensitive))
        {
            start = data.indexOf(KAddressTag);
            end = data.indexOf("</address>", start);
            mTownName = data.mid(start + KAddressTag.length(), end - start - KAddressTag.length());
        }
        else if(data.contains(KFormattedAddressTag, Qt::CaseInsensitive))
        {
            start = data.indexOf(KFormattedAddressTag);
            end = data.indexOf("</formatted_address>", start);
            mTownName = data.mid(start + KFormattedAddressTag.length(), end - start - KFormattedAddressTag.length());

        }
        else
        {
            qDebug() << "Data format error";
            mTownName = "Unknown Place";
        }
    }
    else
    {
        qDebug() << "Http reply error";
        mTownName = "Unknown Place";
    }

    emit localDone(mLatitude, mLongitude, mTownName);
    mHttpReply->deleteLater();
    mHttpReply = NULL;

    if(mDownloadMyMap && QNetworkReply::OperationCanceledError != replyError)
    {
        downloadMap(mLongitude, mLatitude);
    }
    else if(mDownloadMyMap)
    {
        emit slippyMapReady("");
    }
}

void TwtLocation::handleSlippymapData()
{
    qDebug() << "TwtLocation::handleSlippymapData()";
    qDebug() << mHttpReply->error();

    if(mRequestTimer->isActive())
    {
        mRequestTimer->stop();
    }

    disconnect(mHttpReply, SIGNAL(finished()), this, SLOT(handleSlippymapData()));
    QImage img;
    QString path("");
    if (QNetworkReply::NoError == mHttpReply->error())
    {
        if (img.load(mHttpReply, 0))
        {
            QString appPath = qApp->applicationDirPath();
            QString mapFile = appPath + "/slippyMap.png";
            QFile file(mapFile);
            qDebug() << "save map to file " <<mapFile;
            if ( file.open(QIODevice::WriteOnly) )
            {
                img.save(&file);
                file.close();
                path = mapFile;
            }
        }
    }
    emit slippyMapReady(path);
    mHttpReply->deleteLater();
    mHttpReply = NULL;
}

// end of file
