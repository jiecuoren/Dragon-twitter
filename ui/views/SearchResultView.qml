import QtQuick 1.0

import "../components"
import "../models"

Item {
    id: container

    //every view should have this property
    property int viewId: application.kSearchResultView
    property int deleteBehaviour: viewmanager.deleteOnBack

    property string queryText: ''
    property alias title: title.text
    property alias buttonText: leftBtn.text

    //every view should define below two functions
    function handleActivation()
    {
        console.log("Search Results View  is activated");
        if ( 0 === tweetsList.model.count )
        {
            tweetsList.getTweetsApi.setSearchText( queryText );
            tweetsList.setMainTextTopBarLeftText( queryText );
            tweetsList.getNewTweets();
        }
    }

    function handleDeactivation()
    {
        console.log("Search Results View  is deactivated");
    }

    width: parent.width
    height: parent.height

    Image {
        id: topBar
        anchors{ top: parent.top }
        source: application.getImageSource("bg_topzone.png");

        Button {
            id: leftBtn
            pressIcon: application.getImageSource("button_bg_01_press.png");
            normalIcon: application.getImageSource("button_bg_01_normal.png");
            x: 10
            text: "Search"
            textFontSize: 21
            textColor: "#F0FFFF"
            anchors {verticalCenter: parent.verticalCenter}

            onClicked: {
                console.log("left btn in more page clicked!");
                viewmanager.back( viewmanager.slideRight );
            }
        }

        Text {
            id: title
            width: parent.width - leftBtn.width - leftBtn.anchors.leftMargin
                      - rightBtn.width - rightBtn.anchors.rightMargin - 25
            anchors{top: leftBtn.top; left: leftBtn.right; leftMargin: 10}
            font {pixelSize: 30; family: "Catriel"; bold: true}
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "white"
            text: "trending now"
            elide: Text.ElideRight
        }

        Button {
            id: rightBtn
            pressIcon: application.getImageSource("home_button_write_press.png");
            normalIcon: application.getImageSource("home_button_write_normal.png");
            anchors {verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 17}
            onClicked: {
                console.log("right btn in more page clicked!");
                viewmanager.activateViewById(application.kNewTwitterView, viewmanager.slidePopup);
            }
        }

    }// end of topbar

    TweetsList {
        id: tweetsList
        model: ModelSearchResult{}
        supportRefresh: true
        anchors {left: parent.left; right: parent.right; top: topBar.bottom; bottom: parent.bottom}

    }

    Component.onCompleted: {
        //setup APIs for tweetsList
        var getTweetsApi = Qt.createComponent("../apis/ApiSearch.qml").createObject(tweetsList);
        tweetsList.setGetTweetsApi(getTweetsApi);
    }

}
