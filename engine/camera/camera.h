#ifndef TWTCAMERA_H
#define TWTCAMERA_H

#include <QObject>

#ifdef Q_OS_SYMBIAN
const TUid KUidCamera = { 0x101F857A };
#endif

class TwtCamera : public QObject
{
    Q_OBJECT
public:
    explicit TwtCamera(QObject* aParent = 0);
    ~TwtCamera();

//interface
public:
    /**
     * open camera
     */
    Q_INVOKABLE void openCamera();

signals:
    void imgCaptured(QString aFileName);
};

#endif // TWTCAMERA_H
