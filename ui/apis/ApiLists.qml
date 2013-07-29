import QtQuick 1.0
import TwitterEngine 1.0
import "../models"

Item {
    id : container

    property int requestType
    property int kOwnLists: 0
    property int kFollowedLists: 1
    property int kFollowingLists: 2

    property string _ownLists: "https://api.twitter.com/1/lists.json"
    //get lists that you followed
    property string _followedLists: "https://api.twitter.com/1/lists/subscriptions.json"
    //get lists that following you
    property string _followingLists: "https://api.twitter.com/1/lists/memberships.json"

    signal dataReceived()
    signal errorOccured()

    //request all lists by id
    // if id == "", that's means get authed user lists.
    function getLists(screenName)
    {
        console.log("api lists getLists");
        console.log();

        var parameters = new Array();

        if(screenName !== "")
        {
            parameters.push(["screen_name", screenName]);
        }

        if(parameters.length !== 0)
        {
            application.getOAuth().webRequest(listsRequest, false, getRequestUrl(), parameters,
                                              listsRecevied, errorCallback);
        }
        else
        {
            application.getOAuth().webRequest(listsRequest, false, getRequestUrl(), "",
                                                      listsRecevied, errorCallback);
        }
    }

    function errorCallback(data)
    {
        console.log("error in ApiLists" + data);
        errorOccured();
    }

    function listsRecevied( aReturnStr )
    {
        //console.log("lists api finished: " + aReturnStr);
        listsModel.parseReturnData( aReturnStr );
        container.dataReceived();
    }

    function getRequestUrl()
    {
        switch (requestType)
        {
        case kOwnLists:
            return _ownLists;

        case kFollowedLists:
            return _followedLists;

        case kFollowingLists:
            return _followingLists;

        default:
            return "";
        }
    }

    HttpRequest {
        id: listsRequest
    }

}
