import TwitterEngine 1.0

ApiTimelineBase {
    property int requestType
    property int kTypeRetweetedToMe: 0
    property int kTypeRetweetedByMe: 1
    property int kTypeRetweetsOfMe: 2

    property string _url_retweeted_by_me: "https://api.twitter.com/1/statuses/retweeted_by_me.json"
    property string _url_retweeted_to_me: "https://api.twitter.com/1/statuses/retweeted_to_me.json"
    property string _url_retweets_of_me:  "https://api.twitter.com/1/statuses/retweets_of_me.json"

    function getNewTweets()
    {
        console.log("ApiRetweets::getNewTweets");
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

        application.getOAuth().webRequest(timelineRequest, false, getTimelineUrl(),
                                          params, newTweetsReceived, errorCallback);
    }

    function getOldTweets()
    {
        console.log("ApiRetweets::getOldTweets");
        if (_isLastPage)
        {
            return;
        }

        var max_id = targetModel.get(targetModel.count - 1).id;
        var params = new Array();
        params.push(["max_id", max_id]);
        params.push(["include_rts", "true"]);
        params.push(["include_entities", "true"]);

        application.getOAuth().webRequest(timelineRequest, false, getTimelineUrl(),
                                          params, oldTweetsReceived, errorCallback);
    }

    function getTimelineUrl()
    {
        switch (requestType)
        {
        case kTypeRetweetedByMe:
            return _url_retweeted_by_me;

        case kTypeRetweetedToMe:
            return _url_retweeted_to_me;

        case kTypeRetweetsOfMe:
            return _url_retweets_of_me;

        default:
            return "";
        }
    }

    HttpRequest {
        id: timelineRequest
    }
}
