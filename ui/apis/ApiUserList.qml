import QtQuick 1.0
import TwitterEngine 1.0
import "../models"

Item {
    id : container
    //in this api, we just get 5000 ids at most.

    property ListModel targetModel

    //default is get followings
    property string requestType: "Following"

    property string _requestFollowing: "Following"
    property string _requestFollower: "Followers"

    //first step, get users id list
    property string _getFollowing: "https://api.twitter.com/1/friends/ids.json"
    property string _getFollower: "https://api.twitter.com/1/followers/ids.json"

    //second step, get users info list by the array from first step
    property string _lookUpUserInfo: "https://api.twitter.com/1/users/lookup.json"

    //search user need
    property string _search: "https://api.twitter.com/1/users/search.json"
    property int _thePage: 1

    //follow someone
    property string _followCreate : "https://api.twitter.com/1/friendships/create.json"
    property string _followDestory: "https://api.twitter.com/1/friendships/destroy.json"

    property string _cursor: "-1"

    property int _currentPage: 0

    property bool _isLastPage: false

    property variant ids

    signal dataReceived()
    signal errorOccured()
    signal lastPageReached()

    signal followSuccessfully()
    signal unfollowSuccessfully()

    signal followFailed()
    signal unfollowFailed()

    function followCreate( user_id )
    {
        var params = new Array();

        params.push(["user_id", user_id]);

        application.getOAuth().webRequest( followCreateRequest, true, _followCreate,
                                          params, followCreateReceived, followErrorCallback);
    }

    function followDestory( user_id )
    {
        var params = new Array();

        params.push(["user_id", user_id]);

        application.getOAuth().webRequest( followDestoryRequest, true, _followDestory,
                                          params, followDestoryReceived, unfollowErrorCallback);
    }

    function searchUser( query , page )
    {
        if( query === "" )
        {
            return;
        }
        _thePage = page;
        var params = new Array();

        params.push(["q", query]);
        params.push(["page", _thePage]);
        params.push(["per_page", "20"]);
        params.push(["include_entities", "true"]);
        application.getOAuth().webRequest(searchRequest, false, _search,
                                          params, searchUserReceived, errorCallback);
    }

    function searchUserReceived(data)
    {
        console.log("searchUserReceived"+data);
        if ( _thePage === 1 )
        {
            targetModel.clear();
        }

        var canGetMoreData = targetModel.parseReturnData(data);

        container.dataReceived();

        if ( !canGetMoreData )
        {
            container.lastPageReached();
        }
    }

    function followCreateReceived(data)
    {
        console.log("followCreateReceived"+data);
        container.followSuccessfully()

    }

    function followDestoryReceived(data)
    {
        console.log("followDestoryReceived"+data);
        container.unfollowSuccessfully()
    }

    function intiUserIds(screenName)
    {
        console.log("api user list intiUserIds");

        if(screenName === "")
        {
            console.log("should pass a screen name!");
            return;
        }

        var parameters = new Array();
        var requestStr = "";

        if(requestType == _requestFollowing)
        {
            requestStr = _getFollowing;
        }
        else if(requestType == _requestFollower)
        {
            requestStr = _getFollower;
        }

        parameters.push(["screen_name", screenName]);
        parameters.push(["cursor", _cursor]);
        parameters.push(["stringify_ids", "true"]);

        application.getOAuth().webRequest(idsRequest, false, requestStr, parameters,
                                          parserIds, errorCallback);
    }

    function requestUserInfo()
    {
        console.log("requestUserInfo in ApiUserList");

        console.log("currentPage is " + _currentPage);

        if(_isLastPage)
        {
            console.log("last page reached in api user list");
            return;
        }

        if(ids.length === 0 )
        {
            console.log("ids.length === 0");
            return;
        }

        if(_currentPage > 9)
        {
            console.log("too much user loaded! we should emit lastPageReached, currentPage is " + _currentPage);
            _isLastPage = true;
            container.lastPageReached();
            return;
        }

        var parameters = new Array();

        parameters.push(["include_entities", "true"]);

        if(ids.length > 20)
        {
            parameters.push(["user_id", ids.slice(_currentPage * 20, Math.min((++_currentPage) * 20), ids.length).join(",")]);
        }
        else
        {
            parameters.push(["user_id", ids.join(",")]);
        }

        application.getOAuth().webRequest(userinfoRequest, false, _lookUpUserInfo, parameters,
                                          parseUserInfo, errorCallback);
    }

    function parserIds( returnData )
    {
        console.log("parserIds in ApiUserList" + returnData);

        var jsonObject = eval('(' + returnData + ')');

        if ( typeof (jsonObject ) === "object" )
        {
            if( 0 !== jsonObject.ids.length)
            {
                console.log("jsonObject.ids.length is " + jsonObject.ids.length);

                ids = jsonObject.ids
                requestUserInfo();
            }
        }
    }

    function parseUserInfo(returnData)
    {
        console.log("parseUserInfo " + returnData);
        var canGetMoreData = targetModel.parseReturnData(returnData);
        container.dataReceived();

        if(!canGetMoreData)
        {
            _isLastPage = true;
            container.lastPageReached();
        }
    }

    function errorCallback(data)
    {
        console.log("error in ApiUserList" + data);
        container.errorOccured();
    }

    function followErrorCallback(data)
    {
        console.log("followErrorCallback in ApiUserList" + data);
        container.followFailed();
    }

    function unfollowErrorCallback(data)
    {
        console.log("unfollowErrorCallback in ApiUserList" + data);
        container.unfollowFailed();
    }

    HttpRequest {
        id: idsRequest
    }

    HttpRequest {
        id: userinfoRequest
    }

    HttpRequest {
        id: searchRequest
    }

    HttpRequest {
        id: followCreateRequest
    }

    HttpRequest {
        id: followDestoryRequest
    }
}
