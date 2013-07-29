#include <QDebug>

#ifdef Q_OS_SYMBIAN
#include <aknappui.h>
#endif

#include "orientation.h"

TwtOrientation::TwtOrientation(QObject *parent) : QObject(parent)
{

}

TwtOrientation::~TwtOrientation()
{

}

void TwtOrientation::setOrientationLandscape()
{
#ifdef Q_OS_SYMBIAN
    if (iAvkonAppUi)
    {
        iAvkonAppUi->SetOrientationL(CAknAppUi::EAppUiOrientationLandscape);
    }
#endif
}

void TwtOrientation::setOrientationPortrait()
{
#ifdef Q_OS_SYMBIAN
    if (iAvkonAppUi)
    {
        iAvkonAppUi->SetOrientationL(CAknAppUi::EAppUiOrientationPortrait);
    }
#endif
}
