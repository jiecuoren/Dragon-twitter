import QtQuick 1.0
import TwitterEngine 1.0

ApiTimelineBase {
    id : container

    signal addFavoriteSuccessfully(string id)
    signal deleteFavoriteSuccessfully(string id)
    signal addFavoriteError();
    signal deleteFavoriteError();
    signal retweetedSuccessfully();
    signal retweetedError();
    signal deleteStatusSuccessfully(string id);
    signal deleteStatusError();

    property string _homeTimeline: "https://api.twitter.com/1/statuses/home_timeline.json"
    property string _mentions: "https://api.twitter.com/1/statuses/mentions.json"
    property string _addfavorite:"https://api.twitter.com/1/favorites/create/"
    property string _deletefavorite: "https://api.twitter.com/1/favorites/destroy/"
    property string _retweeted: "https://api.twitter.com/1/statuses/retweet/"
    property string _deleteStatus:"https://api.twitter.com/1/statuses/destroy/"

    function getNewTweets()
    {
        console.log("ApiHomeTimeline::getNewTweets");
        var since_id = "";
        if (targetModel.count > 0)
        {
            since_id = targetModel.get(0).id;
        }

        var params = new Array();
        if (since_id !== "")
        {
            params.push(["since_id", since_id]);
        }

        params.push(["include_rts", "true"]);
        params.push(["include_entities", "true"]);
        application.getOAuth().webRequest(timelineRequest, false, _homeTimeline,
                                          params, newTweetsReceived, errorCallback);
    }

    function getOldTweets()
    {
        console.log("ApiHomeTimeline::getOldTweets");
        if (_isLastPage)
        {
            return;
        }

        var max_id = targetModel.get(targetModel.count - 1).id;
        var params = new Array();
        params.push(["max_id", max_id]);
        params.push(["include_rts", "true"]);
        params.push(["include_entities", "true"]);
        application.getOAuth().webRequest(timelineRequest, false, _homeTimeline,
                                          params, oldTweetsReceived, errorCallback);
    }

    function addToFavorite( id )
    {
        console.log("Api Blog List, addToFavorite");
        var addfavorite = _addfavorite + id + ".json";
        application.getOAuth().webRequest( addFavRequest, true, addfavorite, '', addFavoriteCallback, addErrorCallback );
    }

    function deleteFromFavorite( id )
    {
        console.log("Api Blog List, deleteFromFavorite");
        var deletefavorite = _deletefavorite + id + ".json";
        application.getOAuth().webRequest( deleteFavRequest, true, deletefavorite, '', deleteFavoriteCallback, deleteErrorCallback );
    }

    function retweet( id )
    {
        console.log("Api Blog List, retweet");
        var retweeted = _retweeted + id + ".json";
        application.getOAuth().webRequest( retweetedRequest, true, retweeted, '', retweetedCallback, retweetedErrorCallback );
    }

    function deleteStatus( id )
    {
        console.log("Api Blog List, deleteStatus"+id);
        var deleteStatus = _deleteStatus + id + ".json";
        application.getOAuth().webRequest( deleteSatusRequest, true, deleteStatus, '', deleteStatusCallback, deleteStatusErrorCallback );
    }
    
    function addErrorCallback(data)
    {
        console.log(" add error happend",data);
        container.addFavoriteError();
    }

    function deleteErrorCallback(data)
    {
        console.log("delete error happend",data);
        container.deleteFavoriteError();
    }

    function addFavoriteCallback(data)
    {
        console.log("addFavoriteCallback, response is " + data);
        var jsonObject = eval ('(' + data + ')');
        container.addFavoriteSuccessfully(jsonObject.id_str);
    }

    function deleteFavoriteCallback( data )
    {
        console.log("deleteFavoriteCallback, response is " + data);
        var jsonObject = eval ('(' + data + ')');
        container.deleteFavoriteSuccessfully(jsonObject.id_str);
    }

    function retweetedErrorCallback( data )
    {
        console.log(" retweeted error happend",data);
        container.retweetedError();
    }

    function retweetedCallback( data )
    {
        console.log(" retweeted successfully",data);
        container.retweetedSuccessfully();
    }

    function deleteStatusErrorCallback( data )
    {
        console.log(" delete Status error happend",data);
        container.deleteStatusError();
    }

    function deleteStatusCallback( data )
    {
        console.log(" delete Status successfully",data);
        var jsonObject = eval ('(' + data + ')');
        container.deleteStatusSuccessfully(jsonObject.id_str);
    }

    HttpRequest {
        id: timelineRequest
    }

    HttpRequest {
        id: addFavRequest
    }

    HttpRequest {
        id: deleteFavRequest
    }
    HttpRequest {
        id: deleteSatusRequest
    }

    HttpRequest {
        id: retweetedRequest
    }
}
