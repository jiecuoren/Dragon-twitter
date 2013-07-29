import QtQuick 1.0
import "../components"

Item {
    id: container
    width: parent.width //parent is viewmanager(360 x 610)
    height: parent.height

    //every view should have this property
    property int viewId: application.kUserListView
    property int deleteBehaviour: viewmanager.deleteOnBack

    //each view should have left btn text;
    //the title string is the left btn string of next view
    property alias _leftBtnStr: leftBtn.text
    property alias _titleStr: title.text

    property string _screenName: ""

    //every view should define below two functions
    function handleActivation()
    {
        console.log("user list view is activated");
        if (0 === listView.model.count)
        {
            listView.intiUserIds(_screenName)
        }
    }

    function handleDeactivation()
    {
        console.log("user list view is deactivated");
    }

    //aTitleStr also indicate the requestType of api
    function setViewProperty(aLeftBtnStr, aTitleStr, aScreenName)
    {
        console.log("user list view in setViewProperty");
        _leftBtnStr = " " + aLeftBtnStr;
        _titleStr = aTitleStr;
        _screenName = aScreenName;
        listView.getUserApi.requestType = aTitleStr
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
                console.log("left btn in user list clicked!");
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
            elide: Text.ElideRight
        }

        Button {
            id: rightBtn
            pressIcon: application.getImageSource("home_button_write_press.png");
            normalIcon: application.getImageSource("home_button_write_normal.png");
            anchors {verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 17}
            textFontSize: 18
            textColor: "white"
            onClicked: {
                console.log("right btn in user list clicked!");
                viewmanager.activateViewById(application.kNewTwitterView, viewmanager.slidePopup);
            }
        }
    }// end of navigationBar


    UserList {
        id: listView
        width: parent.width
        anchors{top: navigationBar.bottom; bottom: parent.bottom}

        onItemSelected: {
            console.log("User list clicked");
            var view = viewmanager.getView(kUserProfileView, true);
            view.setProfileInfo(listView.model.get(index), false);
            view.setNavBarText(container._titleStr, listView.model.get(index).screen_name);
            viewmanager.activateView(view, viewmanager.slideLeft);
        }
    }

    Component.onCompleted: {
        //setup APIs for UserList
        var getUserApi = Qt.createComponent("../apis/ApiUserList.qml").createObject(listView);
        listView.setGetUserApi(getUserApi);
    }
}
