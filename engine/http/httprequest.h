#ifndef HTTP_REQUEST_H
#define HTTP_REQUEST_H

#include <QObject>

class QNetworkAccessManager;
class QNetworkReply;
class QNetworkRequest;
class QTimer;
class QSslError;

//gloable variable for access maneger
extern QNetworkAccessManager* gUniqueNetwrkManager;

class HttpRequest : public QObject
{
    Q_OBJECT

public:
    explicit HttpRequest(QObject *aParent = 0);
    ~HttpRequest();

//interface
public:
    /**
     * set http request header.
     * @aValue, a base64 encoding of data
     */
    Q_INVOKABLE void setHeader(const QString &akey, const QString &aValue);

    /**
     * http get method
     * @aUrl, request url
     */
    Q_INVOKABLE void get(const QString &aUrl);

    /**
     * http post method
     * @aUrl, request url
     * @aBody has a default value " "
     */
    Q_INVOKABLE void post(const QString &aUrl);

    /**
     * cancel request
     */
    Q_INVOKABLE void cancel();

    /**
     * http upload method
     * @aUrl, request url
     * @aContent, content
     * @aFileName pic file to upload
     */
    Q_INVOKABLE void upload(const QString& aUrl, const QString& aContent, const QString& aFilePath);

    Q_INVOKABLE void disconnectAllConnections();

signals:
    void loadingFinished(QString aReturnStr);
    void loadingError(QString aErrorStr);

private slots:
    void onReplyFinished();
    void onRequestTimeout();
    void onSslErrors(QNetworkReply* aReply, const QList<QSslError>& aErr);

private:
    QNetworkReply *mReply;
    QNetworkRequest* mRequest;
    QTimer *mRequestTimeoutTimer;
};

#endif /* HTTP_REQUEST_H */
