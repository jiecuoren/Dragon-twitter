#ifndef TWTLOCATION_H
#define TWTLOCATION_H

#include <QObject>
#include <QNetworkSession>
#include <QNetworkReply>

//// QtMobility API headers
#include <qmobilityglobal.h>

QTM_BEGIN_NAMESPACE
class QGeoPositionInfoSource;
class QGeoSatelliteInfoSource;
class QGeoPositionInfo;
class QGeoSatelliteInfo;
QTM_END_NAMESPACE

class QTimer;

// Use the QtMobility namespace
QTM_USE_NAMESPACE

class TwtLocation: public QObject
{
    Q_OBJECT

public:
    TwtLocation(QObject* parent = 0);
    ~TwtLocation();

//interface
public:
    /**
     * start to get location and slippy map
     */
    Q_INVOKABLE void start(bool downMap = false);

    /**
     * start to download slippy map with center of (longitude, latitude)
     */
    Q_INVOKABLE void downloadMap(double longitude, double latitude, int zoom = 15);

    /*
     * get town name by long and lat
     */
    Q_INVOKABLE void requestTownName(double longitude, double latitude);

    /*
     * cancel location related opeeration
     */
    Q_INVOKABLE void cancelOperation();

private slots:
    // QGeoPositionInfoSource
    void positionUpdated(const QGeoPositionInfo &gpsPos);
    void networkSessionOpened();
    void updateTimeout();
    void onRequestTimeout();

    void delayedInit();
    void handleTownNameData();
    void handleSlippymapData();

signals:
    void localDone(double aLat, double aLon, QString aReturnStr);
    void slippyMapReady(QString aFilePath);

private:
    void cancelHttpRequest(QNetworkReply* reply);

private:
    QGeoPositionInfoSource* mLocation;
    QNetworkSession* mSession;
    QNetworkReply* mHttpReply;
    qreal mLatitude;
    qreal mLongitude;
    QString mTownName;
    QTimer *mRequestTimer;
    bool mDownloadMyMap;
};

#endif // TWTLOCATION_H
