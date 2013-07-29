import QtQuick 1.0
import "../javascript/commonFunction.js" as CommonFunction
import "../components"
import "../apis"

Item {
    id: container
    clip: true
    anchors.fill: parent

    property url _profileImage: ""
    property string _name: ""
    property string _screenName: ""

    function positionViewAtBeginning()
    {
        flickArea.contentY = 0;
    }

    function setUserInfo(userInfo, fromSearch)
    {
        console.log("setUserInfo in profile tab");

        //set own property
        if(userInfo.default_profile_image === false)
        {
            _profileImage = userInfo.profile_image_url
        }
        else
        {
            _profileImage = application.getImageSource("avatar_default.png");
        }

        _name = userInfo.name
        _screenName = userInfo.screen_name

        if(!fromSearch)
        {
            setComponentProperty(userInfo)
        }
        else
        {
            apiUserInfo.requestUserInfo(container._screenName);
        }

    }

    function setComponentProperty(userObject)
    {
        //set other info property
        console.log("setComponentProperty userObject is " + userObject);

        // when actived by search view, the name should be reset
        if(userObject.default_profile_image === false)
        {
            _profileImage = userObject.profile_image_url
        }
        else
        {
            _profileImage = application.getImageSource("avatar_default.png");
        }

        _name = userObject.name

        if(typeof( userObject.location) !== "undefined" && userObject.location !== null )
        {
            otherInfo.location = userObject.location
        }
        if(typeof( userObject.url) !== "undefined" && userObject.url !== null)
        {
            otherInfo.url = userObject.url
        }
        if(typeof( userObject.description) !== "undefined" && userObject.url !== null)
        {
            otherInfo.description = userObject.description
        }

        console.log("userObject.created_at is " + userObject.created_at);

        otherInfo.createdAt = CommonFunction.extractFormatedTime(userObject.created_at)
        otherInfo.followingsCount = userObject.friends_count
        otherInfo.followersCount = userObject.followers_count
        otherInfo.tweetsCount = userObject.statuses_count
        otherInfo.favoritesCount = userObject.favourites_count
        otherInfo.screenName = userObject.screen_name

        //init listsModel;
        otherInfo.setComponentProperty();

        otherInfo.visible = true;

        //request friendship
        if(container._screenName != application.screen_name)
        {
            console.log("container._screenName is " + container._screenName);
            console.log("application.screen_name is  " + application.screen_name)
            otherInfo.isOwnProfile = false;
            otherInfo.requestFriendship();
        }
    }

    function resetUserProfile()
    {
        console.log("tabProfileNormal resetUserProfile");
        _name = application.userInfo.name

        if(typeof( application.userInfo.location) !== "undefined" && application.userInfo.location !== null )
        {
            otherInfo.location = application.userInfo.location
        }
        if(typeof( application.userInfo.url) !== "undefined" && application.userInfo.url !== null)
        {
            otherInfo.url = application.userInfo.url
        }
        if(typeof( application.userInfo.description) !== "undefined" && application.userInfo.url !== null)
        {
            otherInfo.description = application.userInfo.description
        }
    }

    ApiUserInfo {
        id: apiUserInfo

        onDataReceived: {
            console.log("tabProfileNormal api user info data receiced");
            setComponentProperty(userObject);
        }

        onErrorOccured: {
            console.log("tabProfileNormal api user info error occured");
        }
    }

    Flickable {
        id: flickArea
        clip: true
        anchors.fill: parent

        contentWidth: parent.width
        contentHeight: otherInfo.y + otherInfo.height + 20

        // area for user icon/name/location. etc.
        Item {
            id: topInfo
            width: parent.width
            height: iconArea.height
            anchors {top:  parent.top; topMargin: 14; left: parent.left; leftMargin: 14}

            ProfileImg {
                id: iconArea
                anchors {left: parent.left; top: parent.top}
                profileSource: container._profileImage
            }

            Text {
                id: userName
                text: container._name
                width: parent.width - iconArea.width - 50
                elide:Text.ElideRight
                font.bold: true
                color: "black"
                anchors {top:  iconArea.top; topMargin: 2; left: iconArea.right; leftMargin: 5}
                font { pixelSize: 20}
            }

            Text {
                id: screenName
                width: userName.width
                text: "@" + container._screenName
                elide:Text.ElideRight
                color: "black"
                font {pixelSize: 18}
                anchors {left: userName.left; top: userName.bottom; topMargin: 3 }
            }
        }// end of topInfo

        //other info
         ProfileComponent{
            id: otherInfo
            anchors{top: topInfo.bottom}
            visible: false

            onFollowingBtnClicked: {
                var view = viewmanager.getView(kUserListView, true);
                var leftBtnText = _screenName;
                if(leftBtnText == application.screen_name)
                {
                    leftBtnText = "My Profile"
                }
                view.setViewProperty(leftBtnText, "Following", _screenName);
                viewmanager.activateView(view, viewmanager.slideLeft);
            }

            onFollowersBtnClicked: {
                var view = viewmanager.getView(kUserListView, true);
                var leftBtnText = _screenName;
                if(leftBtnText == application.screen_name)
                {
                    leftBtnText = "My Profile"
                }
                view.setViewProperty(leftBtnText, "Followers", _screenName);
                viewmanager.activateView(view, viewmanager.slideLeft);
            }

            onFavoritesBtnClicked: {
                viewmanager.currentView().getTabByIndex(3)
            }

            onTweetsBtnClicked: {
                viewmanager.currentView().getTabByIndex(1)
            }

            onLocationBtnClicked: {
                var view = viewmanager.getView(kProfileLocation, false);
                view.screenName = _screenName;
                view.address = address;
                viewmanager.activateView(view, viewmanager.slideLeft);
            }
        }

         LoadingDlg {
             id: loadingdlg
             anchors{centerIn: parent; verticalCenterOffset: -80}
             visible: !otherInfo.visible
         }

    }

}
