import QtQuick 1.0
import TwitterEngine 1.0

import "../components"
import "../models"
import "../components/keyboard"

Item {
    id: container

    //every view should have this property
    property int viewId: application.kSearchTweetsView
    property int deleteBehaviour: viewmanager.deleteOnBack

    property alias queryText: inputText.editorText
    property int selectedIndex: 0

    property double _latitude : 39.5427
    property double _longitude : 116.2317
    property int _searchPage: 1

    //every view should define below two functions
    function handleActivation()
    {
        console.log("Search Tweets View  is activated");
    }

    function handleDeactivation()
    {
        console.log("Search Tweets View  is deactivated");
    }

    function getGeoLocation( lati, longi )
    {
        var location = ''
        if ( validLatitude(lati) && validLongitude(longi) )
        {
            location = String( lati ) + "," + String( longi ) + "," + "5km"
        }
        return location;
    }

    function validLatitude(lat)
    {
        if(lat >= -90.0 && lat <= 90.0)
            return true;
        return false;
    }

    function validLongitude(lon)
    {
        if(lon >= -180.0 && lon <= 180.0)
            return true;
        return false;
    }

    function startLocation()
    {
        location.start(false);
    }

    function doSearch( index )
    {
        switch( index )
        {
        case 0:

            allTweetsList.getTweetsApi.setSearchText( queryText );
            allTweetsList.setMainTextTopBarLeftText( queryText );
            allTweetsList.getNewTweets();

            break;
        case 1:

            nearByList.getTweetsApi.setSearchText( queryText );
            nearByList.getTweetsApi.setGeoCode( getGeoLocation( _latitude,_longitude ) );
            nearByList.setMainTextTopBarLeftText( queryText );
            nearByList.getNewTweets();

            break;
        case 2:

            peopleList.searchUser( queryText, _searchPage );

            break;
        default:
            break;
        }
    }

    width: parent.width
    height: parent.height

    TweetsList {
        id: allTweetsList
        visible: container.selectedIndex === 0
        opacity: container.selectedIndex === 0 ? 1.0 : 0.0
        model: ModelSearchResult{}
        supportRefresh: true
        anchors {left: parent.left; right: parent.right; top: categoryBarImage.bottom; bottom: parent.bottom }

    }

    TweetsList {
        id: nearByList
        visible: container.selectedIndex === 1
        opacity: container.selectedIndex === 1 ? 1.0 : 0.0
        model: ModelSearchResult{}
        supportRefresh: true
        anchors {left: parent.left; right: parent.right; top: categoryBarImage.bottom; bottom: parent.bottom }

    }

    UserList {
        id: peopleList
        anchors {left: parent.left; right: parent.right; top: categoryBarImage.bottom; bottom: parent.bottom }
        supportRefresh: true
        visible: container.selectedIndex === 2
        opacity: container.selectedIndex === 2 ? 1.0 : 0.0
        onItemSelected: {
            console.log("User list clicked");
            var view = viewmanager.getView(kUserProfileView, true);
            view.setProfileInfo(peopleList.model.get(index), false);
            view.setNavBarText("Search", peopleList.model.get(index).screen_name);
            viewmanager.activateView(view, viewmanager.slideLeft);
        }

        onRefreshTriggered: {
            _searchPage = 1;
            peopleList.searchUser( queryText, _searchPage );
        }

        onLoadMoreTriggered: {
            _searchPage++;
            peopleList.searchUser( queryText, _searchPage );
        }
    }

    CustomEditor {
        id: inputText

        anchors {
            top: searchBarImage.top;
            topMargin: 15
        }

        editorX: 45
        width: parent.width - cancelBtn.width - 20 - inputText.anchors.leftMargin
               - searchGo.width - inputText.editorX
        height: 30
        textFontSize:  21
        textColor: "gray"
        maxInputTextLength: 40
        textWrapMode: TextEdit.NoWrap

    }

    Image {
        id : searchBarImage
        z: -1
        source: application.getImageSource("searchbar_02.png");

        Text {
            id: inputDisaplyText
            anchors {
                verticalCenter: parent.verticalCenter;
                left: parent.left;
                leftMargin: 45
            }
            font {pixelSize: 18; family: "Catriel"}
            color: "gray"
            focus: true
            text: "Search for topic or name"
            visible: inputText.editorText === '' ? true : false
        }

        Button {
            id: searchGo
            visible: inputText.editorText === "" ? false : true
            normalIcon: application.getImageSource("button_gosearch_normal.png");
            pressIcon: application.getImageSource("button_gosearch_press.png");
            anchors {
                right: cancelBtn.left;
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }

            onClicked: {
                console.log("searchGo btn in more page clicked!");
                inputText.hideKeyboard();
                doSearch( selectedIndex );
            }
        }

        Button {
            id: cancelBtn
            pressIcon: application.getImageSource("button_cancel_press.png");
            normalIcon: application.getImageSource("button_cancel_normal.png");
            text: "Cancel"
            x: 10
            textFontSize: 21
            textColor: "white"
            textFontBold: true
            anchors {verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 10}

            onClicked: {
                console.log("cancel btn in more page clicked!");
                viewmanager.back( viewmanager.slideRight );
            }
        }

    }

    Image {
        id : categoryBarImage
        source: application.getImageSource("categorybar.png");
        anchors.top: searchBarImage.bottom

        MouseArea {
            id : tweetsArea
            width: ( parent.width-16) /3
            height: ( parent.height-16)
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 8
            }
            onClicked: {
                console.log("tweetsArea mouse area is clicked");
                container.selectedIndex = 0;

            }
        }

        MouseArea {
            id : geoArea
            width: ( parent.width-16 ) /3
            height: ( parent.height-16 )
            anchors {
                verticalCenter: parent.verticalCenter
                left: tweetsArea.right
            }
            onClicked: {
                console.log("geoArea mouse area is clicked");
                container.selectedIndex = 1;

            }
        }

        MouseArea {
            id : peopleArea
            width: ( parent.width-16 ) /3
            height: ( parent.height-16)
            anchors {
                verticalCenter: parent.verticalCenter
                left: geoArea.right
            }
            onClicked: {
                console.log("peopleBtn mouse area is clicked");
                container.selectedIndex = 2;

            }
        }

        Text {
            id: tweetsText
            anchors.centerIn: tweetsArea
            font { pixelSize: 18; family: "Catriel";bold: true }
            color: container.selectedIndex === 0 ? "white":"gray"
            text: "All Tweets"

        }

        Text {
            id: geoText
            anchors.centerIn: geoArea
            font { pixelSize: 18; family: "Catriel";bold: true }
            color: container.selectedIndex === 1 ? "white":"gray"
            text: "Nearby"

        }

        Text {
            id: peopleText
            anchors.centerIn: peopleArea
            font { pixelSize: 18; family: "Catriel"; bold: true }
            color: container.selectedIndex === 2 ? "white":"gray"
            text: "People"
        }

        Image {
            id: tweetsBtn
            source: application.getImageSource("categorybar_press_left.png");
            visible: container.selectedIndex === 0
            anchors {verticalCenter: parent.verticalCenter;left: parent.left;leftMargin: 8 }
        }

        Image {
            id: geoBtn
            source: application.getImageSource("categorybar_press_mid.png");
            visible: container.selectedIndex === 1
            anchors {verticalCenter: parent.verticalCenter; left:tweetsBtn.right}
        }

        Image {
            id: peopleBtn
            source: application.getImageSource("categorybar_press_right.png");
            visible: container.selectedIndex === 2
            anchors {verticalCenter: parent.verticalCenter; left:geoBtn.right}
        }

    }

    TwtLocation {
        id: location
        onLocalDone: {
            _latitude = aLat;
            _longitude = aLon;

        }
    }

    Component.onCompleted: {
        //setup APIs for allTweetsList
        var getTweetsApi = Qt.createComponent("../apis/ApiSearch.qml").createObject( allTweetsList );
        allTweetsList.setGetTweetsApi(getTweetsApi);
        //setup APIs for nearByList
        var getNearByTweetsApi = Qt.createComponent("../apis/ApiSearch.qml").createObject( nearByList );
        nearByList.setGetTweetsApi(getNearByTweetsApi);
        //setup APIs for peopleList
        var getUserApi = Qt.createComponent("../apis/ApiUserList.qml").createObject( peopleList );
        peopleList.setGetUserApi(getUserApi);
        startLocation();
    }

}
