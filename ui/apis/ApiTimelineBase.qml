import QtQuick 1.0

Item {
    id : container

    property ListModel targetModel

    signal dataReceived(bool isNewTweets)
    signal errorOccured()
    signal lastPageReached()

    property bool _isLastPage: false

    function errorCallback(data)
    {
        console.log(data);
        errorOccured();
    }

    function newTweetsReceived(data)
    {
        var currentCount = targetModel.count;
        var canGetMoreData = targetModel.parseReturnData(data);

        container.dataReceived(true);

        if (0 === currentCount && !canGetMoreData)
        {
            container.lastPageReached();
        }
    }

    function oldTweetsReceived(data)
    {
        var canGetMoreData = targetModel.parseReturnData(data);
        container.dataReceived(false);
        _isLastPage = !canGetMoreData;

        if (_isLastPage)
        {
            container.lastPageReached();
        }
    }
}
