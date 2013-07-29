import QtQuick 1.0

import "../components"
import "../apis"
import "../models"

Item {
    id: container

    //every view should have this property
    property int viewId: application.kSuggestedUsersView
    property int deleteBehaviour: viewmanager.deleteOnBack

    property alias title: title.text
    property alias buttonText: leftBtn.text
    property string slug: ''

    //every view should define below two functions
    function handleActivation()
    {
        console.log("Suggested USERS View  is activated");
        if ( userListModel.count ===0 )
        {
            suggestionsApi.setSlug( slug );
            suggestionsApi.getSuggestionsBySlug();
        }
    }

    function handleDeactivation()
    {
        console.log("Suggested USERS View  is deactivated");
    }

    width: parent.width
    height: parent.height

    ApiSuggestions {
        id : suggestionsApi
        onDataReceived: {
            loadingdlg.visible = false;
        }
        onErrorOccured: {
            loadingdlg.visible = false;
        }
        onLastPageReached:{
            console.log("Suggested USERS VIEW  onLastPageReached");
            listView.reachEnd = true;
        }
    }

    ModelUserList {
        id :userListModel

    }

    Image {
        id: toolBar
        anchors{ top: parent.top }
        source: application.getImageSource("bg_topzone.png");
        Button {
            id: leftBtn
            pressIcon: application.getImageSource("button_bg_01_press.png");
            normalIcon: application.getImageSource("button_bg_01_normal.png");
            x: 10
            text: "Search"
            textFontSize: 16
            textColor: "white"
            textFontBold: true
            anchors {verticalCenter: parent.verticalCenter}

            onClicked: {
                console.log("left btn in more page clicked!");
                viewmanager.back( viewmanager.slideRight );
            }
        }

        Text {
            id: title
            anchors{verticalCenter: parent.verticalCenter; left: leftBtn.right; leftMargin: 10; right: parent.right}
            font {pixelSize: 24; family: "Catriel"; bold: true}
            color: "white"
            elide: Text.ElideRight
        }

    }// end of toolbar

    UserList {
        id: listView
        anchors {left: parent.left; right: parent.right; top: toolBar.bottom; bottom: parent.bottom }
        model: userListModel
        delegate: UserListComponent2{}
        supportRefresh: false
        supportFollow: true

        onItemSelected: {
            console.log("User list clicked");
            var view = viewmanager.getView(kUserProfileView, true);
            view.setProfileInfo(listView.model.get(index), false);
            view.setNavBarText(container.slug, listView.model.get(index).screen_name);
            viewmanager.activateView(view, viewmanager.slideLeft);
        }

    }

    LoadingDlg {
        id: loadingdlg
        anchors{
            top: parent.top
            bottom: parent.bottom
        }
    }

    Component.onCompleted: {
        //setup APIs for userList
        var getUserApi = Qt.createComponent("../apis/ApiUserList.qml").createObject( listView );
        listView.setGetUserApi(getUserApi);
    }

}
