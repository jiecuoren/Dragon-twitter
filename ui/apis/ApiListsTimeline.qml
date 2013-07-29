import TwitterEngine 1.0

ApiTimelineBase {

    property string _listsId: ""
    property string _listsTimeline: "https://api.twitter.com/1/lists/statuses.json"

    function setListsId(aId)
    {
        console.log("ApiListsTimeline setListsId");
        _listsId = aId;
    }

    function getNewTweets()
    {
        console.log("ApiListsTimeline::getNewTweets");
        var params = new Array();

        var since_id = "";
        if (targetModel.count > 0)
        {
            since_id = targetModel.get(0).id;
        }

        if (since_id !== "")
        {
            params.push(["since_id", since_id]);
        }

        if(_listsId !== "")
        {
            params.push(["list_id", _listsId]);
        }

        params.push(["include_rts", "true"]);
        params.push(["include_entities", "true"]);
        application.getOAuth().webRequest(timelineRequest, false, _listsTimeline,
                                          params, newTweetsReceived, errorCallback);
    }

    function getOldTweets()
    {
        console.log("ApiListsTimeline::getOldTweets");
        if (_isLastPage)
        {
            return;
        }

        var params = new Array();

        var max_id = targetModel.get(targetModel.count - 1).id;
        params.push(["max_id", max_id]);

        if(_listsId !== "")
        {
            params.push(["list_id", _listsId]);
        }
        params.push(["include_rts", "true"]);
        params.push(["include_entities", "true"]);

        application.getOAuth().webRequest(timelineRequest, false, _listsTimeline,
                                          params, oldTweetsReceived, errorCallback);
    }

    HttpRequest {
        id: timelineRequest
    }
}
