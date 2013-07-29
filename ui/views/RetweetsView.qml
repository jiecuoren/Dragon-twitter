import QtQuick 1.0
import "../components"

Item {
    id: container
    width: parent.width //parent is viewmanager(360 x 610)
    height: parent.height

    //every view should have this property
    property int viewId: application.kRetweetsView
    property int deleteBehaviour: viewmanager.deleteOnBack

    property alias _titleStr: title.text

    //every view should define below two functions
    function handleActivation()
    {
        console.log("Retweentview is activated");
        if (tweetsList.model.count === 0)
        {
            tweetsList.getNewTweets();
        }
    }

    function handleDeactivation()
    {
        console.log("Retweentview is deactivated");
    }

    function setViewProperty(aTitleStr, apiType)
    {
        console.log("Retweentview in setViewProperty");
        _titleStr = aTitleStr
        tweetsList.setMainTextTopBarLeftText( _titleStr );
        tweetsList.getTweetsApi.requestType = apiType;
    }

    Image {
        id: navigationBar
        anchors{top: parent.top}
        source: application.getImageSource("bg_topzone.png");

        Button {
            id: leftBtn
            pressIcon: application.getImageSource("button_bg_01_press.png");
            normalIcon: application.getImageSource("button_bg_01_normal.png");
            x: 10
            textFontSize: 18
            textColor: "white"
            text: " My Profile"
            anchors {verticalCenter: parent.verticalCenter}

            onClicked: {
                viewmanager.back(viewmanager.slideRight);
            }
        }

        Text {
            id: title
            width: parent.width - leftBtn.x - leftBtn.width - title.anchors.leftMargin
            anchors {left: leftBtn.right; leftMargin: 20; verticalCenter: parent.verticalCenter}
            elide: Text.ElideRight
            font {pixelSize: 22; family: "Catriel"; bold: true}
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "white"
        }
    }// end of navigationBar

    TweetsList {
        id: tweetsList
        width: parent.width
        anchors {top: navigationBar.bottom; bottom: parent.bottom}
    }

    Component.onCompleted: {
        //setup APIs for tweetsList
        var getTweetsApi = Qt.createComponent("../apis/ApiRetweets.qml").createObject(tweetsList);
        tweetsList.setGetTweetsApi(getTweetsApi);
    }
}
