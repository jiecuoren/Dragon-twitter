import QtQuick 1.0

import "../components"

Item {
    id: container
    anchors.fill: parent

    function positionViewAtBeginning()
    {
        tweetsList.setViewAtBeginning();
    }

    onVisibleChanged: {
        console.log("tab at me visible changed");

        if (visible && (0 === tweetsList.model.count))
        {
            tweetsList.setMainTextTopBarLeftText("Mentions");
            tweetsList.getNewTweets();
        }
        else if ( !visible )
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
        var getTweetsApi = Qt.createComponent("../apis/ApiMentions.qml").createObject(tweetsList);
        tweetsList.setGetTweetsApi(getTweetsApi);

        var checkNewTweetApi = Qt.createComponent("../apis/ApiCheckNewMentions.qml").createObject(tweetsList);
        tweetsList.setCheckNewTweetApi(checkNewTweetApi);
    }
}
