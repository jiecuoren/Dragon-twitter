import QtQuick 1.0
import "../components"

Item {
    id: container
    width: parent.width // parent is viewmanager(360 x 610)
    height: parent.height

    //every view should have this property
    property int viewId: application.kProfileLocation
    property int deleteBehaviour: viewmanager.deleteOnBack

    property string screenName : ""
    property string address : ""

    //every view should define below two functions
    function handleActivation()
    {
        loadingdlg.visible = true;
        staticMap.source = getUrl();
    }

    function handleDeactivation()
    {
        loadingdlg.visible = false;
    }

    function getUrl()
    {
        var url = "http://maps.googleapis.com/maps/api/staticmap?center=%1&zoom=%2&size=%3x%4&sensor=false";
        var zoom = "6"
        if (address.search(",") !== -1)
        {
            zoom = "10"
        }
        return url.arg(address).arg(zoom).arg(container.width).arg(defaultMap.height);
    }

    Image {
        id: leftTop
        x: 0
        y: 0
        width: container.width
        source: application.getImageSource("bg_topzone.png");

        Button {
            id: backBtn
            anchors { left: parent.left; leftMargin: 5; verticalCenter: parent.verticalCenter }
            normalIcon: application.getImageSource("button_bg_01_normal.png")
            pressIcon: application.getImageSource("button_bg_01_press.png")
            textColor: "white"
            text: " " + screenName
            onClicked: {
                viewmanager.back(viewmanager.slideRight);
            }
        }
    }

    Image {
        id: defaultMap
        anchors { top: leftTop.bottom
                  topMargin: -50
                  bottom: parent.bottom
                  left: parent.left
                  right: parent.right }
        source: application.getImageSource("worldmap.png")
        visible: true
        opacity: 1.0
    }

    Image {
        id: staticMap
        anchors { top: leftTop.bottom
                  bottom: parent.bottom
                  left: parent.left
                  right: parent.right }
        source: ""
        onStatusChanged: {
            if(status == Image.Loading)
            {
                defaultMap.opacity = 1.0;
                defaultMap.visible = true;
                loadingdlg.visible = true;
            }
            else if(status == Image.Ready)
            {
                defaultMap.opacity = 0.0;
                defaultMap.visible = false;
                loadingdlg.visible = false;
            }
            else if(status == Image.Error)
            {
                loadingdlg.visible = false;
            }
        }
    }

    LoadingDlg {
        id: loadingdlg
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
}
