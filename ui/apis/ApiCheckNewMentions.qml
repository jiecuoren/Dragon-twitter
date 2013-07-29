import QtQuick 1.0
import TwitterEngine 1.0

Item {
    id: container

    property ListModel targetModel

    signal newTweetFound()

    property string _mentions: "https://api.twitter.com/1/statuses/mentions.json"

    function checkNewTweet()
    {
        var tweetID = "";
        if (targetModel.count > 0)
        {
            tweetID = targetModel.get(0).id;
        }

        var params = new Array();
        if (tweetID !== "") {
            params.push(["since_id", tweetID]);
        }
        params.push(["count", "1"]);
        params.push(["trim_user", "true"]);

        application.getOAuth().webRequest(checkNewRequest, false, _mentions, params,
                                          checkNewMentionsCallback, errorCallback);
    }


    function checkNewMentionsCallback(data)
    {
        console.log("checkNewMentionsCallback, response is " + data);
        if (data !== "[]")
        {
            container.newTweetFound();
        }
    }

    function errorCallback(data)
    {
        console.log(data);
    }

    HttpRequest {
        id: checkNewRequest
    }
}
