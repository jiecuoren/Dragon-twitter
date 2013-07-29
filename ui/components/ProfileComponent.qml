import QtQuick 1.0
import TwitterEngine 1.0
import "../components"

Item {
    id: container
    width: parent.width
    height: infoContainer.height

    property bool isOwnProfile: true

    //private property, api address
    property string _friendships: "https://api.twitter.com/1/friendships/show.json"
    property string _followCreate: "https://api.twitter.com/1/friendships/create.json"
    property string _followDestroy: "https://api.twitter.com/1/friendships/destroy.json"

    //ui text, can be set by parent
    property string screenName: ""
    property string description: ""
    property string location: ""
    property string createdAt: ""
    property string url: ""

    //ui show following, in json it's friends
    property int followingsCount: 0
    property int followersCount: 0

    //ui show tweets, in json it's statuses
    property int tweetsCount: 0
    property int favoritesCount: 0

    //you follow him
    property bool _isFollowing: false
    //he follow you
    property bool _isFollowedBy: false
    property bool _isLoading: true

    signal followingBtnClicked
    signal followersBtnClicked
    signal tweetsBtnClicked
    signal favoritesBtnClicked
    signal locationBtnClicked(string address)


    //list element does not support js function, we must set screenName here
    function setComponentProperty()
    {
        //set lists model
        listsModel.append({"full_name": container.screenName + "'s Lists"});
        listsModel.append({"full_name": "Lists " + container.screenName + " Follows"});
        listsModel.append({"full_name": "Lists Following " + container.screenName});

        //set second part property
        secondPart.setDesHeight()
        secondPart.setLocBtnProperty();
        secondPart.setWebBtnProperty();
    }

    function requestFriendship()
    {
        console.log("requestFriendship in profile tab");
        _isLoading = true;
        var parameters = new Array();

        parameters.push(["source_screen_name", application.screen_name]);
        parameters.push(["target_screen_name", container.screenName]);

        application.getOAuth().webRequest(request, false, _friendships, parameters,
                                          parserFriendship, errorCallback);
    }

    function parserFriendship(returnData)
    {
        console.log("parserFriendship in profile tab" + returnData);
        var jsonObject = eval('(' + returnData + ')');

        if ( typeof (jsonObject ) === "object" )
        {
            container._isFollowing = jsonObject.relationship.target.followed_by

            container._isFollowedBy = jsonObject.relationship.source.followed_by
            console.log("jsonObject.relationship.target.followed_by " + jsonObject.relationship.target.followed_by)
            if (_isFollowedBy)
            {
                var profileView = viewmanager.getView(application.kUserProfileView, false);
                profileView.appendReplyModel();
            }
        }

        isFollowBtn.text = _isFollowing ? "Unfollow" : "Follow"
        isFollowBtn.enabled = true;
        _isLoading = false;
    }

    function updateFollowState()
    {
        console.log("updateFollowState in profile component");
        isFollowBtn.text = "";
        _isLoading = true;
        isFollowBtn.enabled = false;

        var parameters = new Array();

        parameters.push(["screen_name", screenName]);

        var apiStr = _followDestroy;
        if(!_isFollowing)
        {
            apiStr = _followCreate;
        }

        application.getOAuth().webRequest(request, true, apiStr, parameters,
                                          parserFollowState, errorCallback);
    }

    function parserFollowState(returnData)
    {
        console.log("parserFollowState in profile component");

        var jsonObject = eval('(' + returnData + ')');
        if( typeof (jsonObject ) === "object"               //if profile_background_tile is boolean, that means request success
                &&  typeof (jsonObject.profile_background_tile) === "boolean")
        {
            console.log("in parserFollowState")
            _isFollowing = !_isFollowing;
            if(_isFollowing)
            {
                ++followersCount;
            }
            else
            {
                if(followersCount > 0 )
                {
                    --followersCount;
                }
            }

        }
        isFollowBtn.text = _isFollowing ? "Unfollow" : "Follow"
        isFollowBtn.enabled = true;
        _isLoading = false;
    }

    function errorCallback()
    {
        console.log("error in friendshipRequest in profile component");
        isFollowBtn.text = _isFollowing ? "Unfollow" : "Follow"
        isFollowBtn.enabled = true;
        _isLoading = false;
    }

    Item {
        id: infoContainer
        clip: true
        width: parent.width
        height: isFollowBtn.height + isFollowStr.height + secondPart.height +
                thirdPart.height + retweetsBtn.height + listsBtn.height + createdTime.height + 100
        anchors.top: parent.top

        //first part, follow/unfollow btn & follow text
        SimpleButton {
            id: isFollowBtn
            pressIcon: _isLoading ? application.getImageSource("button_single_normal.png") : application.getImageSource("button_single_press.png")
            normalIcon: application.getImageSource("button_single_normal.png")
            anchors.horizontalCenter: parent.horizontalCenter
            y: 20
            visible: isOwnProfile ? false : true
            height:  isOwnProfile ? 0 : 60
            enabled: false
            textColor: "blue"

            Image {
                id: loadingImg
                source: application.getImageSource("loading_01.png")
                visible: _isLoading
                anchors.centerIn: parent

                NumberAnimation on rotation {
                      running: loadingImg.visible
                      from: 0; to: 360
                      loops: Animation.Infinite;
                      duration: 1200
                  }
            }

            onClicked: {
                console.log("isFollow btn clicked");
                updateFollowState();
            }
        }

        Text {
            id: isFollowStr
            text: _isFollowedBy ? container.screenName + " follows " + application.screen_name
                                            : container.screenName + " does not follow " + application.screen_name
            visible: (!isOwnProfile && !loadingImg.visible) ? true : false
            height:  (!isOwnProfile && !loadingImg.visible) ? 16 : 0
            font.pixelSize: 16;
            color: "black"
            elide: Text.ElideMiddle
            anchors{top: isFollowBtn.bottom; topMargin: 5; horizontalCenter: parent.horizontalCenter}
        }

        //second part, user description/location/web address
        Column {
             id: secondPart
             spacing: 2
             anchors{top:isFollowStr.bottom; topMargin: isOwnProfile ? -10 : 10; horizontalCenter: parent.horizontalCenter}

             function setDesHeight()
             {
                 console.log("profile component setDesHeight");
                 if(description === "")
                 {
                     userDes.height = 0;
                     userDes.visible = false;
                 }
                 else if(location === "" && url === "") // if location & web both empty, the pic should be change
                 {
                     userDes.source = application.getImageSource("button_single_normal.png");
                 }
             }

             function setLocBtnProperty()
             {
                 console.log("profile component setLocBtnProperty");

                 if(location === "")
                 {
                     locationBtn.height = 0;
                     locationBtn.visible = false;
                 }
                 else // if location string is not empty
                 {
                     //1. description === "" && url === "", means single button
                     if(description === "" && url === "")
                     {
                         locationBtn.pressIcon = application.getImageSource("button_single_press.png");
                         locationBtn.normalIcon = application.getImageSource("button_single_normal.png");
                     }

                     //2. location is the first btn, pic should change to top
                     if(description === ""  && url !== "")
                     {
                         locationBtn.pressIcon = application.getImageSource("list_press_top.png");
                         locationBtn.normalIcon = application.getImageSource("list_bg_top.png");
                     }

                     //3. location is the last btn, pic should change to bottom
                     if(description !== ""  && url === "")
                     {
                         locationBtn.pressIcon = application.getImageSource("list_press_bottom.png");
                         locationBtn.normalIcon = application.getImageSource("list_bg_bottom.png");
                     }
                     //4. defailt is the middle btn case
                 }

             }

             function setWebBtnProperty()
             {
                 console.log("profile component setWebBtnProperty");

                 if(url === "")
                 {
                     webBtn.height = 0;
                     webBtn.visible = false;
                 }
                 else if(description === "" && location === "")//description === "" && location === "", means single button
                 {
                     webBtn.pressIcon = application.getImageSource("button_single_press.png");
                     webBtn.normalIcon = application.getImageSource("button_single_normal.png");
                 }
             }

             BorderImage {
                 id: userDes
                 source: application.getImageSource("list_bg_top.png");
                 width: parent.width
                 height: (desText.height < 60 ) ? 60 : desText.height
                 border.left: 3; border.top: 3
                 border.right: 3; border.bottom: 3
                 anchors.horizontalCenter: parent.horizontalCenter

                 Text {
                     id: desText
                     text: container.description.trim()
                     width: parent.width - 10
                     font.pixelSize: 16;
                     color: "#403F41"
                     wrapMode: Text.WordWrap
                     anchors{left: parent.left; leftMargin: 5; verticalCenter: parent.verticalCenter}
                 }
             }

             SimpleButton {
                 id: locationBtn
                 pressIcon: application.getImageSource("list_press_mid.png");
                 normalIcon: application.getImageSource("list_bg_mid.png");
                 text: "location"
                 textColor: "blue"
                 textX: 10
                 textFontSize: 16
                 onClicked: {
                     console.log("locationBtn clicked");
                     container.locationBtnClicked(location);
                 }

                 Text {
                     id: locStr
                     text: container.location
                     width: parent.width - 140
                     font.pixelSize: 20;
                     color: "black"
                     wrapMode: Text.WordWrap
                     elide: Text.ElideRight
                     anchors{left: parent.left; leftMargin: 100; verticalCenter: parent.verticalCenter}
                 }

                 Image {
                     id: secondLineArrow
                     source: application.getImageSource("button_arrow_right.png")
                     anchors {right: locationBtn.right; rightMargin: 5; verticalCenter: parent.verticalCenter}
                 }
             }

             SimpleButton {
                 id: webBtn
                 pressIcon: application.getImageSource("list_press_bottom.png");
                 normalIcon: application.getImageSource("list_bg_bottom.png");
                 text: "web"
                 textColor: "blue"
                 textFontSize: 16
                 textX: 35
                 onClicked: {
                     console.log("webBtn clicked");
                     Qt.openUrlExternally( container.url );
                 }

                 Text {
                     id: webStr
                     text: container.url
                     width: parent.width - 140
                     font.pixelSize: 20;
                     color: "black"
                     wrapMode: Text.WordWrap
                     elide: Text.ElideRight
                     anchors{left: parent.left; leftMargin: 100; verticalCenter: parent.verticalCenter}
                 }

                 Image {
                     id: thirdLineArrow
                     source: application.getImageSource("button_arrow_right.png")
                     anchors {right: webBtn.right; rightMargin: 5; verticalCenter: parent.verticalCenter}
                 }
             }
         }// end of column

        //third part, following count/tweets count/follow count/favorites count
        Grid {
            id: thirdPart
            spacing: 2
            anchors.horizontalCenter: parent.horizontalCenter
            y: secondPart.y + secondPart.height + 20

            columns: 2
            rows: 2

            SimpleButton {
                id: followingBtn
                pressIcon: application.getImageSource("list_press_topleft.png")
                normalIcon: application.getImageSource("list_bg_topleft.png");
                enabled: 0 != container.followingsCount
                text: "following"
                textColor: "blue"
                textFontSize: 16
                textY: 35
                onClicked: {
                    console.log("followingBtn clicked");
                    container.followingBtnClicked();
                }

                Text {
                    color: "black"
                    font {pixelSize: 28; bold: true}
                    text: container.followingsCount
                    y: 5
                    x: (parent.width - width)/2
                }
            }

            SimpleButton {
                id: tweetsBtn
                pressIcon: application.getImageSource("list_press_topright.png")
                normalIcon: application.getImageSource("list_bg_topright.png");
                enabled: 0 !== container.tweetsCount
                text: "tweets"
                textColor: "blue"
                textFontSize: 16
                textY: 35
                onClicked: {
                    console.log("tweetsBtn clicked");
                    container.tweetsBtnClicked();
                }

                Text {
                    color: "black"
                    font {pixelSize: 28; bold: true}
                    text: container.tweetsCount
                    y: 5
                    x: (parent.width - width)/2
                }
            }

            SimpleButton {
                id: followersBtn
                pressIcon: application.getImageSource("list_press_bottomleft.png")
                normalIcon: application.getImageSource("list_bg_bottomleft.png");
                enabled: 0 !== container.followersCount
                text: "followers"
                textColor: "blue"
                textFontSize: 16
                textY: 35
                onClicked: {
                    console.log("followersBtn clicked");
                    container.followersBtnClicked();
                }

                Text {
                    color: "black"
                    font {pixelSize: 28; bold: true}
                    text: container.followersCount
                    y: 5
                    x: (parent.width - width)/2
                }
            }

            SimpleButton {
                id: favoritesBtn
                pressIcon: application.getImageSource("list_press_bottomright.png")
                normalIcon: application.getImageSource("list_bg_bottomright.png");
                enabled: 0 !== container.favoritesCount
                text: "favorites"
                textColor: "blue"
                textFontSize: 16
                textY: 35
                onClicked: {
                    console.log("favoritesBtn clicked");
                    container.favoritesBtnClicked()
                }

                Text {
                    color: "black"
                    font {pixelSize: 28; bold: true}
                    text: container.favoritesCount
                    y: 5
                    x: (parent.width - width)/2
                }
            }
        }// end of Grid

        //fourth part, retweens/lists btn
        CollapsibleButtonList {
            id: retweetsBtn
            titleText: "Retweets"
            y: thirdPart.y + thirdPart.height + 20 * isOwnProfile
            model: retweetsModel
            visible: isOwnProfile ? true : false

            ListModel {
                id: retweetsModel
                ListElement {full_name: "Retweets by Others"}
                ListElement {full_name: "Retweets by Me"}
                ListElement {full_name: "My Tweets, Retweeted"}
            }

            onItemSelected: {
                console.log("retweetsBtn clicked, index is " + index);
                var view = viewmanager.getView(kRetweetsView, true);
                view.setViewProperty(retweetsModel.get(index).full_name, index);
                viewmanager.activateView(view, viewmanager.slideLeft);
            }
        }

        CollapsibleButtonList {
            id: listsBtn
            titleText: "Lists"
            y: retweetsBtn.visible ? retweetsBtn.y + retweetsBtn.height + 20 : thirdPart.y + thirdPart.height + 20
            model: listsModel

            onFooterClicked: {
                console.log("listsBtn footer clicked");
            }

            onItemSelected: {
                console.log("listsBtn clicked, index is " + index);
                var view = viewmanager.getView(kListsView, true);
                view.setViewProperty(" " + _screenName, index); //add " "
                viewmanager.activateView(view, viewmanager.slideLeft);
            }

            ListModel {
                id: listsModel
            }
        }

        //fifth part, join twitter time
        Text {
            id: createdTime
            text: "Joined on " + container.createdAt
            color: "black"
            font.pixelSize: 16
            anchors{ horizontalCenter: parent.horizontalCenter; top: listsBtn.bottom; topMargin: 10}
        }

    }// end of infoContainer

    HttpRequest {
        id: request
    }

}
