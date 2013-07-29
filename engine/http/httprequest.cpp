#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QSslError>
#include <QUrl>
#include <QTimer>
#include <QDebug>
#include <QFile>
#include <QDateTime>

#include "httprequest.h"
#include "imagescaler.h"

const int KRequestTimeOut = 40 * 1000; // 40 s

QNetworkAccessManager* gUniqueNetwrkManager;

HttpRequest::HttpRequest(QObject *aParent) : QObject(aParent), mRequest(NULL)
{
    mRequestTimeoutTimer = new QTimer(this);
    mRequestTimeoutTimer->setSingleShot(true);
    mRequestTimeoutTimer->setInterval(KRequestTimeOut);
    connect(mRequestTimeoutTimer, SIGNAL(timeout()), this, SLOT(onRequestTimeout()));
    connect(gUniqueNetwrkManager, SIGNAL(sslErrors(QNetworkReply*, const QList<QSslError>&)),
            this, SLOT(onSslErrors(QNetworkReply*, const QList<QSslError>&)));

    mRequest = new QNetworkRequest();
}

HttpRequest::~HttpRequest()
{
    if (mRequestTimeoutTimer->isActive())
    {
        mRequestTimeoutTimer->stop();
    }

    delete mRequest;
    mRequest = NULL;

}

void HttpRequest::setHeader(const QString &akey, const QString &aValue)
{
    qDebug() << "HttpRequest::setHeader"<<akey<< aValue;

    if(akey.isEmpty() || aValue.isEmpty())
    {
        return;
    }
    mRequest->setRawHeader(akey.toAscii(), aValue.toAscii());
}

void HttpRequest::get(const QString &aUrl)
{
    qDebug() << "HttpRequest::get()"<< aUrl;

    if (mReply && !mReply->isFinished())
    {
        qDebug() << "last request has not been finished, return";
        return;
    }

    if(aUrl.isEmpty())
    {
        return;
    }

    QByteArray ba;
    ba.append(aUrl);
    mRequest->setUrl(QUrl::fromEncoded(ba));

    if(NULL != gUniqueNetwrkManager)
    {
        mRequestTimeoutTimer->start();
        mReply = gUniqueNetwrkManager->get(*mRequest);
        connect(mReply, SIGNAL(finished()), this, SLOT(onReplyFinished()));
    }
}

void HttpRequest::post(const QString &aUrl)
{
    qDebug() << "HttpRequest::post(const QString& aUrl)"<<aUrl;

    if (mReply && !mReply->isFinished())
    {
        qDebug() << "last request has not been finished, return";
        return;
    }

    if(aUrl.isEmpty())
    {
        return;
    }

    QByteArray ba;
    ba.append(aUrl);
    mRequest->setUrl(QUrl::fromEncoded(ba));

    if(NULL != gUniqueNetwrkManager)
    {
        mRequestTimeoutTimer->start();
        mReply = gUniqueNetwrkManager->post(*mRequest, QByteArray());
        connect(mReply, SIGNAL(finished()), this, SLOT(onReplyFinished()));
    }
}

void HttpRequest::upload(const QString& aUrl, const QString& aContent, const QString& aFilePath)
{
    qDebug() << "HttpRequest::upload(const QString& aUrl, const QString& aFileName)";
    qDebug() << aUrl << "  body is   " + aFilePath.toUtf8();
    if(aUrl.isEmpty())
    {
        return;
    }

    QByteArray ba;
    ba.append(aUrl);
    qDebug() << QUrl::fromEncoded(ba);
    mRequest->setUrl(QUrl::fromEncoded(ba));

    QString fileName = aFilePath.section('\\', -1);
    qsrand(QDateTime::currentDateTime().toTime_t());
    QString b = QVariant(qrand()).toString()+QVariant(qrand()).toString()+QVariant(qrand()).toString();
    QString boundary="---------------------------" + b;

    QByteArray datas(QString("--" + boundary + "\r\n").toAscii());
    datas += "Content-Disposition: form-data; name=\"status\"\r\n";
    datas += "Content-Transfer-Encoding: binary\r\n";
    datas += "Content-Type: text/plain; charset=utf-8\r\n\r\n";

    datas += aContent;
    datas += "\r\n";
    datas += QString("--" + boundary + "\r\n").toAscii();

    datas += "Content-Disposition: form-data; name=\"media[]\"; ";
    datas += "filename=\"" + fileName + "\"\r\n";
    datas += "Content-Transfer-Encoding: binary\r\n";
    datas += "Content-Type: image/jpeg\r\n\r\n";
    qDebug() << datas;
    QFile file(TwtImageScaler::scaled(aFilePath));
    if (!file.open(QIODevice::ReadOnly))
    {
        qDebug() << "HttpRequest::upload open file failed";
        return;
    }
    qDebug() << "HttpRequest::file name" << file.fileName();
    qDebug() << "HttpRequest::file size" << file.size();
    datas += file.readAll();
    datas += "\r\n";
    datas += QString("--" + boundary + "--\r\n").toAscii();
    qDebug() << QString::number(datas.length());
    file.close();

    mRequest->setHeader(QNetworkRequest::ContentLengthHeader, QString::number(datas.length()));
    mRequest->setHeader(QNetworkRequest::ContentTypeHeader, "multipart/form-data; boundary=" + boundary);

    if(NULL != gUniqueNetwrkManager)
    {
        // upload file need more time
        mRequestTimeoutTimer->setInterval(KRequestTimeOut*2);
        mRequestTimeoutTimer->start();
        mReply = gUniqueNetwrkManager->post(*mRequest, datas);
        connect(mReply, SIGNAL(finished()), this, SLOT(onReplyFinished()));
    }
}

void HttpRequest::cancel()
{
    qDebug() << "HttpRequest::cancel()";
    if(NULL != mReply)
    {
        //can't call "reply->abort()" directly, consider finished request.
        mReply->isFinished() ? mReply->close():mReply->abort();
        mReply->deleteLater();
        mReply = NULL;
    }
}

void HttpRequest::disconnectAllConnections()
{
    disconnect();
}

void HttpRequest::onReplyFinished()
{
    qDebug() << "HttpRequest::onReplyFinished()";
    TwtImageScaler::removeTemporaryFile();
    if(mRequestTimeoutTimer->isActive())
    {
        mRequestTimeoutTimer->stop();
    }

    mRequestTimeoutTimer->setInterval(KRequestTimeOut);
    disconnect(mReply, SIGNAL(finished()), this, SLOT(onReplyFinished()));

    QByteArray tempData = mReply->readAll();
    QNetworkReply::NetworkError replyError = mReply->error();
    if(QNetworkReply::NoError == replyError)
    {
        mReply->deleteLater();
        mReply = NULL;
        emit loadingFinished(tempData);
    }
    else
    {
        qDebug() << "HttpRequest::err: " << mReply->errorString();

        QString errStr("Twitter API returned ");
        errStr += QString::number(mReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt());
        errStr += " ";
        errStr += mReply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toByteArray();
        mReply->deleteLater();
        mReply = NULL;
        emit loadingError(errStr);
    }
}

void HttpRequest::onRequestTimeout()
{
    qDebug() << "HttpRequest::onRequestTimeout()";

    if((NULL != mReply) && (mReply->isOpen()))
    {
        mReply->close(); // this will in turn emit QNetworkReply::error(QNetworkReply::OperationCanceledError)
    }
    // No need to send loadingError.
    mRequestTimeoutTimer->setInterval(KRequestTimeOut);
    TwtImageScaler::removeTemporaryFile();
}

void HttpRequest::onSslErrors(QNetworkReply* aReply, const QList<QSslError>& aErr)
{
    foreach (QSslError error, aErr)
    {
        qDebug() << "--> onSslErrors" << error.errorString();
    }
    aReply->ignoreSslErrors(aErr);
}
