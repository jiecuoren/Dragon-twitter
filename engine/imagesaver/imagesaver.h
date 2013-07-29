#ifndef _IMAGE_SAVER
#define _IMAGE_SAVER

#include <QObject>

class QGraphicsObject;

class ImageSaver : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString imagePath READ imagePath WRITE setImagePath NOTIFY imagePathChanged)
public:
    explicit ImageSaver(QObject *aParent = 0);
    ~ImageSaver();

public:
    Q_INVOKABLE void saveImage(QGraphicsObject* aItem);
    void setImagePath(QString aPath);
    QString imagePath();

signals:
    void saveReturned(bool aRetValue);
    void imagePathChanged(QString aDriver);

private:
    void initMembers();

private:
    QString mImagePath;
};

#endif /* _IMAGE_SAVER */
