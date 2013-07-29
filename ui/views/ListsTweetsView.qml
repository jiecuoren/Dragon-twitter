import QtQuick 1.0
import TwitterEngine 1.0
import "../components"

Item {
    id: container
    width: parent.width //parent is viewmanager(360 x 610)
    height: parent.height

    //every view should have this property
    property int viewId: application.kListsTweetsView
    property int deleteBehaviour: viewmanager.deleteOnBack

    property string _id: ""
    property string _name: ""
    property string _screenName: "" // means owner
    property string _slug: ""
    property string _full_name: ""
    property int _subscriber_count: 0
    property int _member_count: 0
    property string _description: ""
    property string _mode: ""
    property bool _following: false
    property variant _user
    property variant _listObject

    //private property, api address
    property string _subscribersCreate: "https://api.twitter.com/1/lists/subscribers/create.json"
    property string _subscribersDestroy: "https://api.twitter.com/1/lists/subscribers/destroy.json"
    property string _listDestroy: "https://api.twitter.com/1/lists/destroy.json"

    //every view should define below two functions
    function handleActivation()
    {
        console.log("list tweets view is activated");
        if (0 === tweetsList.model.count)
        {
            tweetsList.getTweetsApi.setListsId(_id);
            tweetsList.getNewTweets();
        }
    }

    function handleDeactivation()
    {
        console.log("list tweets view is deactivated");
    }

    function setViewProperty(listObject)
    {
        console.log("list tweets view setViewProperty");
        _listObject = listObject

        _name = listObject.name
        _id = listObject.id;
        _slug = listObject.slug;
        _full_name = listObject.full_name;
        _subscriber_count = listObject.subscriber_count;
        _member_count = listObject.member_count;
        _description = listObject.description;
        _following = listObject.following
        _mode = listObject.mode
        _user = listObject.user
        _screenName = listObject.user.screen_name;

        buttonListmodel.clear();

        if(_description.length !== 0)
        {
            buttonListmodel.append({"key" : "description", "value" : _description});
        }
        buttonListmodel.append({"key" : "owner", "value": _screenName });
        buttonListmodel.append({"key" : "following", "value" : _member_count});
        buttonListmodel.append({"key" : "followers", "value" : _subscriber_count});
    }

    function updateListsState()
    {
        console.log("lists tweets view updateListsState");
        loadingdlg.visible = true

        var parameters = new Array();
        var apiStr = _subscribersCreate;
        if(_following)
        {
             apiStr =  _subscribersDestroy
        }

        parameters.push(["list_id", _id]);
        parameters.push(["slug", _slug]);

        application.getOAuth().webRequest(listsRequest, true, apiStr, parameters,
                                          parserReturnData, errorCallback);
    }

    function parserReturnData(returnData)
    {
        console.log("lists tweets view parserReturnData" + returnData);

        var jsonObject = eval('(' + returnData + ')');
        if( typeof (jsonObject ) === "object"               //if following is boolean, that means request success
                &&  typeof (jsonObject.following) === "boolean")
        {
            console.log("in parserFollowState")

            _following = !_following;
            //should update this property!
            _listObject.following = _following;

            var mainview = viewmanager.getView(application.kMainView, false);
            if(!_following)
            {
                if(_subscriber_count > 0)
                {
                    _subscriber_count -= 1
                }
                _listObject.subscriber_count = _subscriber_count
                mainview.removeItem(_id);
            }
            // following == true, append item
            else
            {
                _subscriber_count += 1
                _listObject.subscriber_count = _subscriber_count
                mainview.appendItem(_listObject)
            }
            //update last item of list property
            buttonListmodel.set(buttonListmodel.count - 1, {"key" : "followers", "value" : _subscriber_count});
        }

        rightEndBtn.text = _following ? "Unfollow" : "Follow"
        loadingdlg.visible = false
    }

    function errorCallback()
    {
        console.log("error lists tweets view");
        rightEndBtn.text = _following ? "Unfollow" : "Follow"
        loadingdlg.visible = false
    }

    function handleDeleteCommand( index )
    {
        var view;
        switch ( index )
        {
        case 0:
            backContainer.deleteList();
            //remove titlelist item in mainview
            var mainview = viewmanager.getView(application.kMainView, false);
            mainview.removeItem(_id);
            viewmanager.back(viewmanager.slideRight);
            break;
        default:
            break;
        }
    }

    function handleFollowCommand( index )
    {
        switch ( index )
        {
        case 0:
            updateListsState();
            break;
        default:
            break;
        }
    }

    HttpRequest {
        id: listsRequest
    }

    Image {
        id: navigationBar
        anchors {top: parent.top}
        source: application.getImageSource("bg_topzone.png");

        Button {
            id: leftBtn
            pressIcon: application.getImageSource("button_bg_01_press.png");
            normalIcon: application.getImageSource("button_bg_01_normal.png");
            x: 17 // acoord UI
            text: "Lists"
            textColor: "white"
            anchors {verticalCenter: parent.verticalCenter}

            onClicked: {
                console.log("left btn in home page clicked!");
                viewmanager.back(viewmanager.slideRight);
            }
        }

        Text {
            id: title
            width: parent.width - leftBtn.width - leftBtn.anchors.leftMargin
                      - rightBtn.width - rightBtn.anchors.rightMargin - 25
            anchors{top: leftBtn.top; left: leftBtn.right; leftMargin: 10}
            font {pixelSize: 25; family: "Catriel"; bold: true}
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "white"
            text: _full_name
            elide: Text.ElideRight
        }

        Button {
            id: rightBtn
            pressIcon: application.getImageSource("home_button_write_press.png");
            normalIcon: application.getImageSource("home_button_write_normal.png");
            anchors {verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 17}

            onClicked: {
                console.log("right btn in list tweets clicked!");
                var view = viewmanager.getView(application.kNewTwitterView, false);
                viewmanager.activateView(view, viewmanager.slidePopup);
            }
        }
    }

    // for rotation
    Flipable {
        id: flipableContainer
        width: parent.width
        anchors {top:  navigationBar.bottom; bottom: endBar.top}

        property bool flipped: false

        front: Item {
            id: frontContainer
            anchors.fill: parent

            TweetsList {
                id: tweetsList
                anchors{fill: parent; bottomMargin: -10}
            }
        }

        back: Flickable {
            id: backContainer
            anchors.fill: parent
            contentWidth: parent.width
            contentHeight: deleteBtn.y + deleteBtn.height + 20
            clip: true

            function deleteList()
            {
                console.log("lists tweets view deleteList");
                deleteBtn.enabled = false;
                var parameters = new Array();
                var apiStr = _listDestroy;

                parameters.push(["list_id", _id]);
                parameters.push(["slug", _slug]);

                application.getOAuth().webRequest(listsRequest, true, apiStr, parameters,
                                                  "", "");
            }

            ListModel {
                id: buttonListmodel
            }

            Text {
                id: listsName
                text: _name
                font{pixelSize: 20; bold: true}
                color: "black"
                x: 20
                y: 20
            }

            ButtonList {
                id: propertyListView
                anchors{left: listsName.left; top: listsName.bottom; topMargin: 10}
                model: buttonListmodel
                delegate: SimpleButton {
                    normalIcon: {
                        if(index === 0)
                        {
                            return application.getImageSource("list_bg_top.png")
                        }
                       else if (ListView.view.count -1 == index)
                        {
                            return application.getImageSource("list_bg_bottom.png")
                        }
                        else
                        {
                            return application.getImageSource("list_bg_mid.png")
                        }
                    }

                    pressIcon: {
                        if(key == "owner")
                        {
                            if(index === 0)
                            {
                                return application.getImageSource("list_press_top.png")
                            }
                            else if (ListView.view.count - 1 == index)
                            {
                                return application.getImageSource("list_press_bottom.png")
                            }
                            else
                            {
                                return application.getImageSource("list_press_mid.png")
                            }
                        }
                        else
                        {
                            return normalIcon;
                        }

                    }

                    Text {
                        id: keyText
                        width: key === "description" ? 10 : 100
                        text: key === "description" ? "" : key
                        anchors {left: parent.left; verticalCenter: parent.verticalCenter}
                        horizontalAlignment: Text.AlignRight
                        color: "lightblue"
                    }

                    Text {
                        id: valueText
                        width: 200
                        text: key == "owner" ? "@" + value : value
                        elide: Text.ElideRight
                        anchors {left: keyText.right; leftMargin: 15; verticalCenter: parent.verticalCenter}
                    }

                    Image {
                        id: rightArrow
                        source: key == "owner" ? application.getImageSource("button_arrow_right.png") : ""
                        anchors {verticalCenter: parent.verticalCenter; right: parent.right; }
                    }

                    onClicked: {
                        console.log("Lists tweets view, buttonlist item selected, inde is " + index);
                        ListView.view.itemSelected(index);
                    }
                }

                onItemSelected: {
                    if(model.get(index).key == "owner")
                    {
                        var view = viewmanager.getView(kUserProfileView, true);
                        view.setProfileInfo(_user, false);
                        view.setNavBarText("List", _screenName);
                        viewmanager.activateView(view, viewmanager.slideLeft);
                    }
                }
            } // end of ButtonList

            SimpleButton {
                id: shareBtn
                pressIcon: application.getImageSource("button_single_press.png");
                normalIcon: application.getImageSource("button_single_normal.png");
                anchors{top: propertyListView.bottom; topMargin: -51; horizontalCenter: parent.horizontalCenter}
                text: "Share List"

                onClicked: {
                    var view = viewmanager.getView(application.kNewTwitterView, false);
                    view.setContent(_full_name + " ");
                    viewmanager.activateView(view, viewmanager.slidePopup);
                }
            }

            //deleteBtn can be seen only when check your own lists
            SimpleButton {
                id: deleteBtn
                pressIcon: application.getImageSource("button_single_press.png");
                normalIcon: application.getImageSource("button_single_normal.png");
                anchors{top: shareBtn.bottom; topMargin: 10; horizontalCenter: parent.horizontalCenter}
                text: "Delete List"
                visible: _screenName == application.screen_name

                onClicked: {
                    console.log("Lists tweets view, delete list btn clicked");
                    deleteDialog.active();
                }
            }

        }//end of Flickable

        transform: Rotation {
            id: rotation
            origin.x: flipableContainer.width/2
            origin.y: flipableContainer.height/2
            axis.x: 0; axis.y: 0.5; axis.z: 0
            angle: 0    // the default angle
        }

        states: State {
            name: "back"
            PropertyChanges { target: rotation; angle: 180 }
            when: flipableContainer.flipped
        }

        transitions: Transition {
            NumberAnimation { id: animation; target: rotation; property: "angle"; duration: 650 }
        }
    } //end of Flipable

    Image {
        id: endBar
        anchors {bottom: parent.bottom}
        source: application.getImageSource("home_bottombar.png");

        Button {
            id: leftEndBtn
            pressIcon: flipableContainer.flipped ? application.getImageSource("button_more_press.png")
                                                                    : application.getImageSource("button_info_press.png");
            normalIcon: flipableContainer.flipped ? application.getImageSource("button_more_normal.png")
                                                                      : application.getImageSource("button_info_press.png");
            x: 17 // acoord UI
            anchors {verticalCenter: parent.verticalCenter}

            onClicked: {
                 if(rotation.angle == 180 || rotation.angle == 0)
                 {
                     flipableContainer.flipped = !flipableContainer.flipped
                 }
            }
        }

        Button {
            id: rightEndBtn
            pressIcon: application.getImageSource("button_cancel_press.png");
            normalIcon: application.getImageSource("button_cancel_normal.png");
            disableIcon: application.getImageSource("button_cancel_normal.png");
            anchors {verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 17}
            visible: _screenName != application.screen_name
            textColor: "white"
            text: _following ? "Unfollow" : "Follow"
            textFontSize: 15
            onClicked: {
                console.log("left btn in lists tweets view clicked!");
                updateFollowModel.clear();
                updateFollowModel.append({"displayText": rightEndBtn.text + " List", "destructive": false})
                updateFollowDialog.active();
            }
        }
    }

    LoadingDlg {
        id: loadingdlg
        anchors.fill: parent
        visible: false
    }

    ActionSheet {
        id :deleteDialog
        model: deleteModel
        onItemSelected: {
            console.log("deleteDialog clicked, index is " + index);
            handleDeleteCommand( index );
        }

        ListModel {
            id :deleteModel
            ListElement {displayText:"Delete List"
                        destructive: true}
        }
    }

    ActionSheet {
        id: updateFollowDialog
        model: updateFollowModel
        onItemSelected: {
            console.log("updateFollowDialog clicked, index is " + index);
            handleFollowCommand( index );
        }

        ListModel {
            id :updateFollowModel
        }
    }

    Component.onCompleted: {
        //setup APIs for tweetsList
        var getTweetsApi = Qt.createComponent("../apis/ApiListsTimeline.qml").createObject(tweetsList);
        tweetsList.setGetTweetsApi(getTweetsApi);
    }
}
