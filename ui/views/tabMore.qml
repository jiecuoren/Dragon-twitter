import QtQuick 1.0
import "../apis"
import "../models"
import "../components"
import "../javascript/localdata.js" as LocalDB

Item {
    id: container
    anchors.fill: parent

    function handleActivition()
    {
        console.log(" tab more , handleActivition");
        LocalDB.loadDraftInfo(draftListModel);
    }

    function positionViewAtBeginning()
    {
        flickableArea.contentY = 0;
    }

    function setListsModel(modelObject)
    {
        console.log(" tab more , setListsModel");
        listPanel.model = modelObject;
    }

    // get list
    Component.onCompleted: {
        console.log(" tab more onCompleted");
        LocalDB.loadDraftInfo(draftListModel);
    }

    Flickable {
        id: flickableArea
        clip: true
        anchors {fill: parent}

        contentWidth: parent.width
        contentHeight: aboutBtn.y + aboutBtn.height + 90

        // first part
        Column {
            id: firstPart
            spacing: 2
            x: 20
            y: 20

            SimpleButton {
                id: profileBtn
                pressIcon: application.getImageSource("list_press_top.png");
                normalIcon: application.getImageSource("list_bg_top.png");
                text: "My Profile"
                textColor: "black"
                textX: 10
                onClicked: {
                    console.log("profileBtn clicked");
                    //that means userInfo loading is not finished yet!
                    if(typeof(application.userInfo) === "undefined")
                    {
                        return;
                    }

                    var view = viewmanager.getView(kUserProfileView, true);
                    view.setProfileInfo(application.userInfo, false);
                    view.setNavBarText(" More", " My Profile");
                    viewmanager.activateView(view, viewmanager.slideLeft);
                }

                Image {
                    id: firstLineArrow
                    source: application.getImageSource("button_arrow_right.png")
                    anchors {right: profileBtn.right; rightMargin: 5; verticalCenter: parent.verticalCenter}
                }
            }

            SimpleButton {
                id: favoritesBtn
                pressIcon: application.getImageSource("list_press_mid.png");
                normalIcon: application.getImageSource("list_bg_mid.png");
                text: "Favorites"
                textColor: "black"
                textX: 10
                onClicked: {
                    console.log("favoritesBtn clicked");
                    if(typeof(application.userInfo) === "undefined")
                    {
                        return;
                    }
                    var view = viewmanager.getView(kUserProfileView, true);
                    view.setProfileInfo(application.userInfo, false);
                    view.setNavBarText(" More", " My Profile");
                    view.getTabByIndex(3);
                    viewmanager.activateView(view, viewmanager.slideLeft);
                }

                Image {
                    id: secondLineArrow
                    source: application.getImageSource("button_arrow_right.png")
                    anchors {right: favoritesBtn.right; rightMargin: 5; verticalCenter: parent.verticalCenter}
                }
            }

            SimpleButton {
                id: draftsBtn
                pressIcon: application.getImageSource("list_press_bottom.png");
                normalIcon: application.getImageSource("list_bg_bottom.png");
                text: "Drafts (" + draftListModel.count + ")"
                textColor: "black"
                textX: 10
                onClicked: {
                    var view = viewmanager.getView(application.kDraftListView, false);
                    view.model = draftListModel;
                    viewmanager.activateView(view, viewmanager.slideLeft);
                }

                Image {
                    id: thirdLineArrow
                    source: application.getImageSource("button_arrow_right.png")
                    anchors {right: draftsBtn.right; rightMargin: 5; verticalCenter: parent.verticalCenter}
                }
            }
         }// end of column

        //list part
        Text {
            id: listLable
            text: "Lists"
            font {pixelSize: 25}
            color: "Black"
            x: 30
            y: 226
            visible: listPanel.count != 0
        }

        ButtonList {
            id: listPanel
            x: 20
            y: count ==0 ? 226 : 273
            textWidth: 280

            onItemSelected: {
                console.log("listsBtn clicked, index is " + index);
                var view = viewmanager.getView(kListsTweetsView, true);
                view.setViewProperty(listPanel.model.get(index));
                viewmanager.activateView(view, viewmanager.slideLeft);
            }
        }

        SimpleButton {
            id: voiceNoteBtn
            pressIcon: application.getImageSource("button_single_press.png");
            normalIcon: application.getImageSource("button_single_normal.png");
            enabled: false
            textX: 10
            text: "Voice Notification"
            textColor: "black"
            textFontSize: 22
            anchors {top: listPanel.bottom; topMargin: -51; horizontalCenter: parent.horizontalCenter}
            onClicked: {
                console.log("ratrecommendBtn clicked");
            }

            OnOffSwitch {
                    initValue: application.voiceNote
                    anchors {right: parent.right; rightMargin: 5; verticalCenter: parent.verticalCenter}
                    onValueChanged: {
                        console.log("voice note value changed!, value is " + newValue);
                        application.voiceNote = newValue
                    }
            }
        }

        SimpleButton {
            id: recommendBtn
            pressIcon: application.getImageSource("button_single_press.png");
            normalIcon: application.getImageSource("button_single_normal.png");
            text: "Recommend this app"
            textColor: "black"
            textFontSize: 22
            anchors {top: voiceNoteBtn.bottom; topMargin: 10; horizontalCenter: parent.horizontalCenter}
            onClicked: {
                console.log("ratrecommendBtn clicked");
                var view = viewmanager.getView(application.kMainView, false);
                view.activeRecommendDialog();
            }
        }

        SimpleButton {
            id: rateBtn
            pressIcon: application.getImageSource("button_single_press.png");
            normalIcon: application.getImageSource("button_single_normal.png");
            text: "Rate this app"
            textColor: "black"
            textFontSize: 22
            anchors {top: recommendBtn.bottom; topMargin: 10; horizontalCenter: parent.horizontalCenter}
            onClicked: {
                console.log("rateBtn clicked");
                Qt.openUrlExternally("http://store.ovi.mobi/content/213916");
            }
        }

        SimpleButton {
            id: aboutBtn
            pressIcon: application.getImageSource("button_single_press.png");
            normalIcon: application.getImageSource("button_single_normal.png");
            text: "About"
            textColor: "black"
            anchors {top: rateBtn.bottom; topMargin: 10; horizontalCenter: parent.horizontalCenter}
            onClicked: {
                console.log("aboutBtn clicked");
                var view = viewmanager.getView(kAboutView, true);
                viewmanager.activateView(view, viewmanager.slideLeft);
            }
        }

        ListModel {
            id: draftListModel
        }
    }//end of flickable

}
