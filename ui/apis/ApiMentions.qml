import QtQuick 1.0
import TwitterEngine 1.0

ApiTimelineBase {
    id : container

    property string _mentions: "https://api.twitter.com/1/statuses/mentions.json"

    function getNewTweets()
    {
        console.log("ApiMentions::getNewTweets");
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
        application.getOAuth().webRequest(timelineRequest, false, _mentions,
                                          params, newTweetsReceived, errorCallback);
    }

    function getOldTweets()
    {
        console.log("ApiMentions::getOldTweets");
        if (_isLastPage)
        {
            return;
        }

        var max_id = targetModel.get(targetModel.count - 1).id;
        var params = new Array();
        params.push(["max_id", max_id]);
        params.push(["include_rts", "true"]);
        params.push(["include_entities", "true"]);

        application.getOAuth().webRequest(timelineRequest, false, _mentions,
                                          params, oldTweetsReceived, errorCallback);
    }

    HttpRequest {
        id: timelineRequest
    }
}
