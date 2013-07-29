#include <QApplication>
#include <QDebug>

#ifdef Q_OS_SYMBIAN
#include "NewFileServiceClient.h"
#include <AiwServiceHandler.h>
#include <AiwCommon.hrh>
#endif

#include "camera.h"

/*===============================================================================
  ==============================================================================*/
TwtCamera::TwtCamera(QObject * aParent) :  QObject(aParent)
{
    qDebug() << "TwtCamera::TwtCamera()";
}

TwtCamera::~TwtCamera()
{
    qDebug() << "TwtCamera::~TwtCamera()";
}

void TwtCamera::openCamera()
{
#ifdef Q_OS_SYMBIAN
    qDebug() << "TwtCamera::openCamera";
    CDesCArray* selectedFiles = new (ELeave) CDesCArrayFlat(1);
    CleanupStack::PushL(selectedFiles);

    CNewFileServiceClient* fileClient = NewFileServiceFactory::NewClientL();
    CleanupStack::PushL(fileClient);
    bool result = fileClient->NewFileL(KUidCamera, *selectedFiles, NULL,
                                       ENewFileServiceImage, EFalse);
    if(result)
    {
        TPtrC address = selectedFiles->MdcaPoint(0);
        QString filename = QString::fromUtf16(address.Ptr(), address.Length());
        qDebug() << "TwtCamera::openCamera name = " << filename;
        emit imgCaptured(filename);
    }
    else
    {
        qDebug() << "TwtCamera::openCamera file capture failed";
        emit imgCaptured("");
    }
    CleanupStack::PopAndDestroy( 2 ); // selectedFiles, fileClient
#else
    // for develop on simulator
    emit imgCaptured("");
#endif
}
