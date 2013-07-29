import QtQuick 1.0
import "../models"
import "../components"

Item {
    id: container
    anchors.fill: parent

    property Item getTweetsApi

    function handleActivition()
    {
        console.log("first page view handleActivition");
        if (tweetsList.model.count === 0)
        {
            tweetsList.getNewTweets();
        }
    }

    function positionViewAtBeginning()
    {
        tweetsList.setViewAtBeginning();
    }

    function changeApi(aApi)
    {
        console.log("first page view changeApi");
        if ( tweetsList.supportPopupMenu )
        {
            tweetsList.hidePopUpMenu();
            tweetsList.setHighLightToNull();
        }
        tweetsList.model.clear();
        //must set this !!!
        tweetsList.reachEnd = false;
        if(aApi === null)
        {
            tweetsList.checkNew = true
            tweetsList.setGetTweetsApi(getTweetsApi);
        }
        else
        {
            tweetsList.checkNew = false
            tweetsList.setGetTweetsApi(aApi);
        }
        tweetsList.getNewTweets();

    }

    onVisibleChanged: {
        if ( !visible )
        {
            if ( tweetsList.supportPopupMenu )
            {
                tweetsList.hidePopUpMenu();
            }
        }
    }

    TweetsList {
        id: tweetsList
        anchors { fill: parent }
    }

    Component.onCompleted: {
        //setup APIs for tweetsList
        getTweetsApi = Qt.createComponent("../apis/ApiHomeTimeline.qml").createObject(tweetsList);
        tweetsList.setGetTweetsApi(getTweetsApi);

        var checkNewTweetApi = Qt.createComponent("../apis/ApiCheckNewHomeTweets.qml").createObject(tweetsList);
        tweetsList.setCheckNewTweetApi(checkNewTweetApi);
    }
}
