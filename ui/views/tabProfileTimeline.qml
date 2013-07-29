import QtQuick 1.0
import "../models"
import "../components"

Item {
    id: container
    anchors.fill: parent

    property string _screenName

    function positionViewAtBeginning()
    {
        tweetsList.setViewAtBeginning();
    }

    onVisibleChanged: {
        console.log("tab userTimeline visible changed");

        if (visible && (0 === tweetsList.model.count))
        {
            _screenName = viewmanager.currentView().userInfo.screen_name
            tweetsList.getTweetsApi.setScreenName(_screenName)
            if (application.screen_name === _screenName)
            {
                tweetsList.setMainTextTopBarLeftText( "My Profile" );
            }
            else
            {
                tweetsList.setMainTextTopBarLeftText( _screenName );
            }
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
        anchors.fill: parent
        model: ModelBlogList{}
    }

    Component.onCompleted: {
        //setup APIs for tweetsList
        var getTweetsApi = Qt.createComponent("../apis/ApiUserTimeline.qml").createObject(tweetsList);
        tweetsList.setGetTweetsApi(getTweetsApi);
    }
}
