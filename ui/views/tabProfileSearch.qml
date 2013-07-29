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
        console.log("tab search profile visible changed");

        if (visible && (0 === tweetsList.model.count))
        {
            _screenName = viewmanager.currentView().userInfo.screen_name

            tweetsList.getTweetsApi.setSearchText(encodeURI("@" + _screenName));
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
        model: ModelSearchResult{}
    }

    Component.onCompleted: {
        //setup APIs for tweetsList
        var getTweetsApi = Qt.createComponent("../apis/ApiSearch.qml").createObject(tweetsList);
        tweetsList.setGetTweetsApi(getTweetsApi);
    }
}
