import QtQuick 1.0
import TwitterEngine 1.0

Item {
    id: container

    property string _urlReceivedMessages: "https://api.twitter.com/1/direct_messages.json"
    property string _urlSentMessages: "https://api.twitter.com/1/direct_messages/sent.json"
    property string _urlDestroyMessage: "https://api.twitter.com/1/direct_messages/destroy/"
    property string _urlNewMessage: "https://api.twitter.com/1/direct_messages/new.json"

    //save all the message ids to delete. used in "delete conversion" case
    property ListModel _idsToDelete: ListModel {}

    signal dataReceived()
    signal retrieveAllFinished()
    signal getMessagesError()
    signal errorOccured()
    signal messageDestroyed()
    signal newMessageReceived()
    signal messageSent()
    signal messageSentError()

    function getAllReceivedMessages()
    {
        var params = new Array();
        params.push(["count", "200"]);
        params.push(["skip_status", "true"]);

        application.getOAuth().webRequest(receivedRequest, false, _urlReceivedMessages,
                                          params, receivedMessagesCallback,
                                          getMessagesErrorCallback);
    }

    function getAllSentMessages()
    {
        var params = new Array();
        params.push(["count", "200"]);
        params.push(["skip_status", "true"]);

        application.getOAuth().webRequest(sentRequest, false, _urlSentMessages,
                                          params, sentMessagesCallback,
                                          getMessagesErrorCallback);
    }

    function sendMessage(user_id, screen_name, text)
    {
        var params = new Array();
        params.push(["user_id", user_id]);
        params.push(["screen_name", screen_name]);
        params.push(["text", text]);

        application.getOAuth().webRequest(newRequest, true, _urlNewMessage, params, newMessageCallback,
                                          newMessageErrorCallback);
    }

    function destroyMessage(messageId)
    {
        var url = _urlDestroyMessage + messageId + ".json";
        application.getOAuth().webRequest(destroyRequest, true, url, null, destroyMessageCallback,
                                          destroyMessageErrorCallback);
    }

    function deleteConversion(peer_user_id)
    {
        conversionListModel.deleteMessagesOfPeerUser(peer_user_id, _idsToDelete);
        if (_idsToDelete.count > 0)
        {
            var url = _urlDestroyMessage + _idsToDelete.get(0).messageId + ".json";
            application.getOAuth().webRequest(deleteConversionRequest, true, url, null,
                                              deleteConversionCallback,
                                              deleteConversionErrorCallback);
        }
    }

    function checkNewMessage()
    {
        var params = new Array();

        var since_id = "";
        if (conversionListModel.count > 0)
        {
            since_id = conversionListModel.getSinceId();
        }

        if (since_id !== "")
        {
            params.push(["since_id", since_id]);
        }

        params.push(["skip_status", "true"]);
        application.getOAuth().webRequest(receivedRequest, false, _urlReceivedMessages, params,
                                          checkNewMessageCallback, generalErrorCallback);
    }

    //data callbacks
    function generalErrorCallback(data)
    {
        console.log(data);
        container.errorOccured();
    }

    function getMessagesErrorCallback(data)
    {
        console.log("function getMessagesErrorCallback(data)");
        console.log(data);
        container.getMessagesError();
    }

    function receivedMessagesCallback(data)
    {
        console.log("function receivedMessagesCallback(data)");
        //console.log(data);
        conversionListModel.parseReturnData(data, true);
        getAllSentMessages();
    }

    function sentMessagesCallback(data)
    {
        console.log("function sentMessagesCallback(data)");
        //console.log(data);
        conversionListModel.parseReturnData(data, false);
        if (0 !== conversionListModel.count)
        {
            container.dataReceived();
        }

        container.retrieveAllFinished();
    }

    function newMessageCallback(data)
    {
        console.log("function newMessageCallback(data)");
        //console.log(data);
        conversionListModel.appendSentMessage(data);
        container.messageSent();
    }

    function newMessageErrorCallback(data)
    {
        console.log("function newMessageErrorCallback(data)")
        //console.log(data);
        container.messageSentError();
    }

    function destroyMessageCallback(data)
    {
        console.log("function destroyMessageCallback(data)");
        //console.log(data);
        container.messageDestroyed();
    }

    function destroyMessageErrorCallback(data)
    {
        console.log("function destroyMessageErrorCallback(data)")
        //console.log(data);
        container.messageDestroyed();
    }

    function checkNewMessageCallback(data)
    {
        console.log("function checkNewMessageCallback(data)");
        //console.log(data);
        if (data != "[]")
        {
            var oldCount = conversionListModel.count;
            conversionListModel.appendNewMessages(data);
            if (0 === oldCount)
            {
                container.dataReceived();
            }

            container.newMessageReceived();
        }
    }

    function deleteConversionCallback(data)
    {
        console.log("function deleteConversionCallback(data)");
        _idsToDelete.remove(0);
        if (_idsToDelete.count > 0)
        {
            var url = _urlDestroyMessage + _idsToDelete.get(0).messageId + ".json";
            application.getOAuth().webRequest(deleteConversionRequest, true, url, null,
                                              deleteConversionCallback,
                                              deleteConversionErrorCallback);
        }
    }

    function deleteConversionErrorCallback(data)
    {
        console.log("function deleteConversionErrorCallback(data)")
        _idsToDelete.remove(0);
        if (_idsToDelete.count > 0)
        {
            var url = _urlDestroyMessage + _idsToDelete.get(0).messageId + ".json";
            application.getOAuth().webRequest(deleteConversionRequest, true, url, null,
                                              deleteConversionCallback,
                                              deleteConversionErrorCallback);
        }
    }

    HttpRequest {
        id: receivedRequest
    }

    HttpRequest {
        id: sentRequest
    }

    HttpRequest {
        id: newRequest
    }

    HttpRequest {
        id: destroyRequest
    }

    HttpRequest {
        id: deleteConversionRequest
    }

    HttpRequest {
        id: checkNewRequest
    }
}
