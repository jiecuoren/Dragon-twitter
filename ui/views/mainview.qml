import QtQuick 1.0
import TwitterEngine 1.0
import "../components"
import "../apis"
import "../models"

Item {
    id: mainview
    width: parent.width //parent is viewmanager(360 x 610)
    height: parent.height

    //every view should have this property
    property int viewId: application.kMainView
    property int deleteBehaviour: viewmanager.noDelete

    property Item timeLineApi: null

    //every view should define below two functions
    function handleActivation()
    {
        console.log("main view is activated");

        if(application.getStorage().getKeyValue("voiceNote") !== "")
        {
            application.voiceNote = application.getStorage().getKeyValue("voiceNote");
            console.log("application.voiceNote is " + application.voiceNote);
        }

        if (application.user_id === "")
        {
            application.getAuthorize().requestAccessToken(authorizeFinished);
        }
        else
        {
            apiUserInfo.requestUserInfo(application.screen_name)
            if(titleList.model.count === 2) // only has all & my Tweets
            {
                getUserDefineLists();
            }
            tabsModel.getItemAt(0).handleActivition();
            tabsModel.getItemAt(4).handleActivition();

            //check model. This part for the case: unfollow a list in ListsTweetsView
            //which is current timeline in mainview

            for(var index = 0; index < titleList.model.count; ++index)
            {
                if(titleList.model.get(index).needRemove === true)
                {
                    console.log("titlelist model should delete some item, index is " + index);

                    //1. remove listsModel's item first
                    for(var innerIndex = 0; innerIndex < listsModel.count; ++innerIndex)
                    {
                        if(listsModel.get(innerIndex).id == titleList.model.get(index).id_str)
                        {
                            listsModel.remove(innerIndex);
                            break;
                        }
                    }

                    //2. change api
                    if(titleList.currentIndex == index)
                    {
                        titleList.currentIndex = 0;
                        getTabAtIndex(0).changeApi(null);
                    }

                    //3. then, remove title list item
                    titleList.model.remove(index);
                    --index;
                }
            }
        }
    }

    function handleDeactivation()
    {
        console.log("main view is deactivated");
    }

    function authorizeFinished()
    {
        console.log("main view is authorizeFinished ");

        apiUserInfo.requestUserInfo(application.screen_name)

        if(titleList.model.count === 2)
        {
            getUserDefineLists();
        }
        tabsModel.getItemAt(0).handleActivition();
        tabsModel.getItemAt(2).handleActivition();
        tabsModel.getItemAt(3).handleActivition();
    }

    function getTabAtIndex(index)
    {
        return tabsModel.getItemAt(index);
    }

    // get user defined lists first, then get user followed lists
    // we can not get two kinds of list in one time, cause we use
    // only one api
    function getUserDefineLists()
    {
        console.log("main view, getUserDefineLists()");
        listsModel.clear();
        listsApi.requestType = listsApi.kOwnLists;
        listsApi.getLists(application.screen_name); // first get user defined list
    }

    function appendListModel()
    {
        console.log("main view appendListModel");
        for(var index = 0; index < listsModel.count; ++index)
        {
            titleList.model.append({"itemText":  listsModel.get(index).name,
                                                  "id_str": listsModel.get(index).id,
                                                  "needRemove": false});
        }
    }

    function removeItem(aId)
    {
        console.log("tab home time line,  removeItem, aId is " + aId)
        var index = 0;

        for(index  = 0; index < titleList.model.count; ++index)
        {
            if(titleList.model.get(index).id_str == aId)
            {
                titleList.model.get(index).needRemove = true;
                break;
            }
        }
    }

    function appendItem(listObject)
    {
        console.log("tab home time line appendItem")

        for(var index  = 0; index < titleList.model.count; ++index)
        {
            if(titleList.model.get(index).id_str == listObject.id &&
                    titleList.model.get(index).needRemove === true)
            {
                titleList.model.get(index).needRemove = false;
                return;
            }
        }

        titleList.model.append({"itemText":  listObject.name, "id_str": listObject.id, "needRemove": false});
        listsModel.append(listObject)
    }

    function activeRecommendDialog()
    {
        console.log("main view activeRecommendDialog");
        recommendDialog.active();
    }

    function handleRecommendCommand(index)
    {
        console.log("main view handleRecommendCommand, index is " + index);
        var mailBody = "";
        var subject = "";
        switch ( index )
        {
        case 0:
            mailBody = "http://store.ovi.mobi/content/213916  This's the best twitter client in Ovi ! Try it!";
            Qt.openUrlExternally("sms:?" + "body=" + mailBody)
            break;
        case 1:
            mailBody = "http://store.ovi.mobi/content/213916  This's the best twitter client in Ovi ! Try it!";
            subject = "Best twitter client in Ovi ! ";
            Qt.openUrlExternally("mailto:?subject=" + subject + "&body=" + mailBody);
            break;
        case 2:
            var view = viewmanager.getView(application.kNewTwitterView, false);
            mailBody = Qt.formatTime(new Date(), "hh:mm:ss ap") + " " + "http://store.ovi.mobi/content/213916  Hi, try this twitter client for Symbian, it's great!";
            view.setContent(mailBody);
            viewmanager.activateView(view, viewmanager.slidePopup);
            break;
        default:
            break;
        }
    }

    VisualItemModel {
        id: tabsModel

        function getItemAt(index)
        {
            return children[index].item;
        }

        Tab {
            name: "timeLine"
            inactiveIcon: application.getImageSource("home_button_pop_normal.png")
            activeIcon: application.getImageSource("home_button_pop_press.png")
            source: "tabHomePage.qml"
        }

        Tab {
            name: "@me"
            inactiveIcon: application.getImageSource("home_button_aite_normal.png")
            activeIcon: application.getImageSource("home_button_aite_press.png")
            source: "tabAtMe.qml"
        }

        Tab {
            name: "message"
            inactiveIcon: application.getImageSource("home_button_receive_normal.png")
            activeIcon: application.getImageSource("home_button_receive_press.png")
            source: "tabMessages.qml"
        }

        Tab {
            name: "search"
            inactiveIcon:  application.getImageSource("home_button_search_normal.png")
            activeIcon:  application.getImageSource("home_button_search_press.png")
            source: "tabSearchPage.qml"
        }

        Tab {
            name: "more"
            inactiveIcon: application.getImageSource("home_button_more_normal.png")
            activeIcon:  application.getImageSource("home_button_more_press.png")
            source: "tabMore.qml"
        }
    }

    TabbedUI {
        id: tabUI
        tabIndex: 0
        tabsModel: tabsModel
        anchors {left: parent.left; right: parent.right; top: navigationBar.bottom; bottom: parent.bottom}

        onPreviousTabClicked: {
            tabsModel.getItemAt(tabIndex).positionViewAtBeginning();
        }
    }

    //this ms used for hide titleList when click other area in main window
    MouseArea {
        id: mouseArea
        anchors.fill: parent

        onPressed: {
            console.log("pressed on main view")
            if(titleList.showList) {
                titleList.showList = false;
            }
            else {
                mouse.accepted = false
            }
        }
    }

    Image {
        id: navigationBar
        anchors {top: parent.top}
        source: application.getImageSource("bg_topzone.png");

        Button {
            id: leftBtn
            pressIcon: application.getImageSource("home_button_exit_press.png");
            normalIcon: application.getImageSource("home_button_exit_normal.png");
            x: 17 // acoord UI
            anchors {verticalCenter: parent.verticalCenter}

            onClicked: {
                application.getStorage().setKeyValue("voiceNote", application.voiceNote);
                Qt.quit();
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
            text: application.screen_name
            visible: !titleList.visible
            elide: Text.ElideRight
        }

        TitleList {
            id: titleList
            width: 200
            anchors{top: parent.top; topMargin: 2; horizontalCenter: parent.horizontalCenter}
            z: parent.z + 1
            visible: tabUI.tabIndex === 0

            onItemClicked: {
                console.log("title lists item clicked, index is " + index);

                if(timeLineApi !== null)
                {
                    console.log("timeLineApi != null, need destroy");
                    timeLineApi.destroy();
                }

                if(0 === index)
                {
                    console.log("all tweets should be show");
                    getTabAtIndex(0).changeApi(null);
                }
                else if(1 === index)
                {
                    console.log("my tweets should be show");
                    timeLineApi = Qt.createComponent("../apis/ApiUserTimeline.qml").createObject(mainview);
                    timeLineApi.setScreenName(application.screen_name)
                    getTabAtIndex(0).changeApi(timeLineApi);
                }
                else
                {
                    console.log("user list should be show");
                    timeLineApi = Qt.createComponent("../apis/ApiListsTimeline.qml").createObject(mainview);
                    timeLineApi.setListsId(titleList.model.get(index).id_str)
                    getTabAtIndex(0).changeApi(timeLineApi);
                }

            }
        }

        Button {
            id: rightBtn
            pressIcon: application.getImageSource("home_button_write_press.png");
            normalIcon: application.getImageSource("home_button_write_normal.png");
            anchors {verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 17}

            onClicked: {
                console.log("right btn in home page clicked!");
                var view = viewmanager.getView(application.kNewTwitterView, false);
                viewmanager.activateView(view, viewmanager.slidePopup);
            }
        }
    }

    ApiUserInfo {
        id: apiUserInfo

        onDataReceived: {
            console.log("main view api user info data receiced");
            application.userInfo = userObject;
        }

        onErrorOccured: {
            console.log("main view api user info error occured");
        }
    }

    ApiLists {
        id: listsApi

        onDataReceived: {
            console.log("Data Received in tab home page");
            // update tileList model first
            if(requestType == kOwnLists)
            {
                //request followed list item
                requestType = kFollowedLists;
                getLists(application.screen_name);
            }
            else if(requestType == kFollowedLists)
            {
                appendListModel();
                tabsModel.getItemAt(4).setListsModel(listsModel);
            }
        }

        onErrorOccured: {
            console.log("Error Occured in tab home page");
        }
    }

    ModelLists {
        id: listsModel
    }

    ActionSheet {
        id: recommendDialog
        model: recommendModel
        text: "Share this application \nwith your friend!"
        onItemSelected: {
            console.log("recommendDialog clicked, index is " + index);
            handleRecommendCommand( index );
        }

        ListModel {
            id :recommendModel
            ListElement {displayText:"By SMS"; destructive: false}
            ListElement {displayText:"By Mail"; destructive: false}
            ListElement {displayText:"By Tweet"; destructive: false}
        }
    }

}
