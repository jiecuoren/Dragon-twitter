import QtQuick 1.0
import "../components"
import "../apis"

Item {
    id: container
    width: parent.width //parent is viewmanager(360 x 610)
    height: parent.height

    //every view should have this property
    property int viewId: application.kUserProfileView
    property int deleteBehaviour: viewmanager.deleteOnBack

    //should save userInfo for all tabs in this view
    property variant userInfo: application.userInfo
    property string screen_name: '' //after it's used to get user info, it's set to empty string.
                                    //don't use it for Text

    //each view should have left btn text;
    //the title string is the left btn string of next view
    property alias _leftBtnText: leftBtn.text
    property alias _titleText: title.text

    //every view should define below two functions
    function handleActivation()
    {
        console.log("user profile view is activated");
        if ( screen_name != '')
        {
            userInfoApi.requestUserInfo( screen_name );
        }
    }

    function handleDeactivation()
    {
        console.log("user profile view is deactivated");
    }

    //this function will be called before active profile view.
    //the parametre is a parsered object
    function setProfileInfo(aUserInfo, fromSearch)
    {
        console.log("setProfileInfo in user profile view ");
        userInfo = aUserInfo;
        tabsModel.getItemAt(0).setUserInfo(userInfo,fromSearch);
    }

    function setNavBarText(aLeftBtnText, aTitleText)
    {
        console.log("setNavBarText in user profile view ");
        _leftBtnText = " " + aLeftBtnText;
        _titleText = aTitleText;
    }

    function getTabByIndex(index)
    {
        console.log("getTabByIndex in user profile view, index is " + index);
        tabUI.tabClicked(index);
    }

    function appendReplyModel()
    {
        replyModel.append({"displayText":"Direct Message","destructive":false});
    }

    function resetUserProfile()
    {
        console.log("userprofile resetUserProfile");
        userInfo = application.userInfo;
        setProfileInfo(userInfo,false);
    }

    ApiUserInfo {
        id : userInfoApi
        onDataReceived: {
            console.log("Api User info onDataReceived",userObject);
            setProfileInfo(userObject,false);
            screen_name = ""; //set it to empty string to avoid request user info again in handleActivation
        }
        onErrorOccured: {
            console.log("Api User info onErrorOccured");
        }
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
            anchors {verticalCenter: parent.verticalCenter}

            onClicked: {
                console.log("left btn in profile tab clicked!");
                viewmanager.back(viewmanager.slideRight);
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
            text: _titleText
            elide: Text.ElideRight
        }

        Button {
            id: rightBtn
            normalIcon: (userInfo.screen_name == application.screen_name) ? application.getImageSource("home_button_write_normal.png")
                                                                          : application.getImageSource("home_button_forward_normal.png")
            pressIcon: (userInfo.screen_name == application.screen_name) ? application.getImageSource("home_button_write_press.png")
                                                                         : application.getImageSource("home_button_forward_press.png")
            anchors {verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 17}
            onClicked: {
                if(userInfo.screen_name == application.screen_name)
                {
                    viewmanager.activateViewById(kEditProfileView, viewmanager.slideLeft);
                }
                else
                {
                    replyAction.active();
                }
            }
        }
    }// end of navigationBar

    VisualItemModel {
        id: tabsModel

        function getItemAt(index)
        {
            return children[index].item;
        }

        Tab {
            name: "profile"
            inactiveIcon: application.getImageSource("button_people_normal.png")
            activeIcon: application.getImageSource("button_people_press.png")
            source: "tabProfileNormal.qml"
        }

        Tab {
            name: "timeLine"
            inactiveIcon: application.getImageSource("button_history_normal.png")
            activeIcon: application.getImageSource("button_history_press.png")
            source: "tabProfileTimeline.qml"
        }

        Tab {
            name: "@me"
            inactiveIcon: application.getImageSource("home_button_aite_normal.png")
            activeIcon: application.getImageSource("home_button_aite_normal.png")
            source: "tabProfileSearch.qml"
        }

        Tab {
            name: "favorites"
            inactiveIcon:  application.getImageSource("button_star_normal.png")
            activeIcon:  application.getImageSource("button_star_press.png")
            source: "tabProfileFavorites.qml"
        }

    }

    TabbedUI {
        id: tabUI
        width: parent.width
        tabIndex: 0
        tabsModel: tabsModel
        anchors{top: navigationBar.bottom; bottom: parent.bottom}

        onPreviousTabClicked: {
            tabsModel.getItemAt(tabIndex).positionViewAtBeginning();
        }
    }

    ListModel {
        id: replyModel
        ListElement {displayText: "Public Reply"
                     destructive: false}
    }

    ActionSheet {
        id: replyAction
        model: replyModel

        onItemSelected: {
            handleReplyCommands(index);
        }
    }

    function handleReplyCommands(index)
    {
        var view;
        var tabMessage;
        switch (index)
        {
        case 0:
            //public reply
            view = viewmanager.getView(application.kNewTwitterView, false);
            view.reply_id = userInfo.id_str;
            view.setContent("@" + userInfo.screen_name + " ");
            viewmanager.activateView(view, viewmanager.slidePopup);
            break;

        case 1:
            //direct message
            tabMessage = viewmanager.getView(application.kMainView, false).getTabAtIndex(2);
            tabMessage.gotoConversionViewByPeerUserId(userInfo.id_str, userInfo.screen_name);
            break;

        default:
            break;
        }
    }
 }
