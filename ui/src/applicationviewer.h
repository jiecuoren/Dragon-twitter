#ifndef APPLICATIONVIEWER_H
#define APPLICATIONVIEWER_H

#include <QDeclarativeView>

class ApplicationViewer : public QDeclarativeView
{
public:
    ApplicationViewer();

private:
    void resizeEvent(QResizeEvent *event);
    bool mSetSizeDone;
};

#endif // APPLICATIONVIEWER_H
