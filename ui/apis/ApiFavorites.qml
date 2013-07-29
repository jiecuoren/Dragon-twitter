import TwitterEngine 1.0

ApiTimelineBase {

    property string _screenName: ""
    property string _favorites: "https://api.twitter.com/1/favorites.json"

    function setScreenName(aName)
    {
        console.log("ApiFavorites setScreenName");
        _screenName = aName;
    }

    function getNewTweets()
    {
        console.log("ApiFavorites::getNewTweets");
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

        if(_screenName !== "")
        {
            params.push(["screen_name", _screenName]);
        }

        params.push(["include_rts", "true"]);
        params.push(["include_entities", "true"]);

        application.getOAuth().webRequest(favoritesRequest, false, _favorites,
                                          params, newTweetsReceived, errorCallback);
    }

    function getOldTweets()
    {
        console.log("ApiFavorites::getOldTweets");
        if (_isLastPage)
        {
            return;
        }

        var max_id = targetModel.get(targetModel.count - 1).id;
        var params = new Array();
        params.push(["max_id", max_id]);
        params.push(["include_rts", "true"]);
        params.push(["include_entities", "true"]);
        if(_screenName !== "")
        {
            params.push(["screen_name", _screenName]);
        }

        application.getOAuth().webRequest(favoritesRequest, false, _favorites,
                                          params, oldTweetsReceived, errorCallback);
    }

    HttpRequest {
        id: favoritesRequest
    }
}
