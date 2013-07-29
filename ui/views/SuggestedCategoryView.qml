import QtQuick 1.0

import "../components"
import "../apis"
import "../models"

Item {
    id: container

    //every view should have this property
    property int viewId: application.kSuggestedCategoryView
    property int deleteBehaviour: viewmanager.deleteOnBack

    property alias title: title.text
    property alias buttonText: leftBtn.text

    //every view should define below two functions
    function handleActivation()
    {
        console.log("SuggestedCategory View  is activated");
        if ( suggestionsModel.count === 0 )
        {
            suggestionsApi.getSuggestions();
        }
    }

    function handleDeactivation()
    {
        console.log("SuggestedCategory View  is deactivated");
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
    }

    ModelSuggestions {
        id :suggestionsModel

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
            textFontSize: 21
            textColor: "white"
            textFontBold: true
            anchors {verticalCenter: parent.verticalCenter}

            onClicked: {
                viewmanager.back( viewmanager.slideRight );
            }
        }

        Text {
            id: title
            anchors {verticalCenter: parent.verticalCenter; left: leftBtn.right; leftMargin: 17}
            font {pixelSize: 24; family: "Catriel"; bold: true}
            color: "white"
            text: "Suggested Users"
        }

    }// end of toolbar

    Flickable {
        id : flickable
        width: parent.width
        anchors {
            top : toolBar.bottom;
            bottom: parent.bottom;
        }
        contentWidth: parent.width
        contentHeight:  firstPart.height + 20
        clip : true

        Column {
            id : firstPart
            width: parent.width
            y:10
            spacing: 10

            Text {
                id : browseInterestsText
                anchors.horizontalCenter: parent.horizontalCenter
                font {
                    pixelSize: 21;
                    family: "Catriel";
                }
                color: "gray"
                text: "Browse Interests"
            }

            ButtonList {
                id: listPanel
                anchors {
                    left: parent.left
                    leftMargin: 20
                }
                model: suggestionsModel
                textWidth: 280
                onItemSelected:{
                    console.log(index);
                    var view = viewmanager.getView( application.kSuggestedUsersView, true);
                    view.buttonText = "Suggested Users";
                    view.title = listPanel.model.get(index).full_name;
                    view.slug = listPanel.model.get(index).slug;
                    viewmanager.activateView( view, viewmanager.slideLeft );
                }
            }
        }
    }

    LoadingDlg {
        id: loadingdlg
        anchors{
            top: parent.top
            bottom: parent.bottom
        }
    }

}
