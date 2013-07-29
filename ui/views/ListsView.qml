import QtQuick 1.0
import "../components"
import "../models"
import "../apis"

Item {
    id: container
    width: parent.width //parent is viewmanager(360 x 610)
    height: parent.height

    //every view should have this property
    property int viewId: application.kListsView
    property int deleteBehaviour: viewmanager.deleteOnBack

    property string _screenName: ""

    //every view should define below two functions
    function handleActivation()
    {
        console.log("listsview is activated");
        loadingBg.visible = true;
        listsModel.clear();
        api.getLists(_screenName.trim());
    }

    function handleDeactivation()
    {
        console.log("listsview is deactivated");
    }

    function setViewProperty(aName, aIndex)
    {
        console.log("listsview setViewProperty, name is " + aName)
        _screenName = aName;
        api.requestType = aIndex
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
            text:  (_screenName == application.screen_name) ? " My profile" : _screenName
            anchors {verticalCenter: parent.verticalCenter}

            onClicked: {
                console.log("left btn in user list clicked!");
                viewmanager.back(viewmanager.slideRight);
            }
        }

        Text {
            id: title
            anchors.centerIn: parent
            elide: Text.ElideRight
            font {pixelSize: 30; family: "Catriel"; bold: true}
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "white"
            text: "Lists"
        }
    }// end of navigationBar

    Image {
        id: loadingBg
        source: application.getImageSource("button_single_normal.png")
        anchors {top: navigationBar.bottom; topMargin: 20; horizontalCenter: parent.horizontalCenter}

        Text {
            id: btnText
            anchors {left: parent.left; leftMargin: 15; verticalCenter: parent.verticalCenter}
            color: "black"
            font.pixelSize: 22
        }

        Image {
            id: loadingImg
            source: application.getImageSource("loading_01.png")
            anchors.centerIn: parent

            NumberAnimation on rotation {
                  running: loadingImg.visible
                  from: 0; to: 360
                  loops: Animation.Infinite;
                  duration: 1200
              }
        }
    }

    ButtonList {
        id: mainList
        width: parent.width
        clip: true
        textWidth: 280
        x: 20
        model: listsModel
        visible: !loadingBg.visible
        anchors {top: navigationBar.bottom; topMargin: 20; bottom: parent.bottom; bottomMargin: 10}
        interactive: true

        onItemSelected: {
            var view = viewmanager.getView(kListsTweetsView, true);
            view.setViewProperty(listsModel.get(index))
            viewmanager.activateView(view, viewmanager.slideLeft);
        }
    }

    ModelLists {
        id: listsModel
    }

    ApiLists {
        id: api

        onDataReceived: {
            console.log("api in listsview dataReceived");
            if(listsModel.count == 0)
            {
                btnText.text = "No Lists"
                loadingImg.visible = false;
            }
            else
            {
                loadingBg.visible = false;
            }
        }

        onErrorOccured: {
            console.log("api in listsview error occured");
            btnText.text = "No Lists"
            loadingImg.visible = false;
        }
    }

}
