#ifndef TWTORIENTATION_H
#define TWTORIENTATION_H

#include <QObject>

class TwtOrientation : public QObject
{
    Q_OBJECT

public:
    explicit TwtOrientation(QObject* parent = 0);
    ~TwtOrientation();

public:
    Q_INVOKABLE void setOrientationLandscape();
    Q_INVOKABLE void setOrientationPortrait();
};

#endif // TWTORIENTATION_H
