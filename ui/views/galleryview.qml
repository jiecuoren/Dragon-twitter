import QtQuick 1.0
import "../components"

Flickable {
    id: container
    width: parent.width // parent is viewmanager(360 x 610)
    height: parent.height
    interactive: false
    contentHeight: parent.height
    contentWidth: parent.width * 2
    contentX: 0

    //every view should have this property
    property int viewId: application.kGalleyView
    property int deleteBehaviour: viewmanager.deleteOnBack
    property bool hasPhotos: false
    //two model should be set firstly
    property alias albumModel: albumlist.model
    property alias photosModel: photosgrid.model

    //every view should define below two functions
    function handleActivation()
    {
        console.log("gallery view handleActivation");
    }

    function handleDeactivation()
    {

    }

    Image {
        id: leftTop
        x: 0
        y: 0
        width: container.width
        source: application.getImageSource("bg_topzone.png");

        Button {
            id: cancelBtn
            anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
            normalIcon: application.getImageSource("button_cancel_normal.png")
            pressIcon: application.getImageSource("button_cancel_press.png")
            text: "Cancel"
            textColor: "white"
            onClicked: {
                console.log("click to back to new twitter view");
                viewmanager.back(viewmanager.slidePopdown);
            }
        }

        Text {
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            text: "Photo Albums"
            color: "#F0FFFF"
            font { pixelSize: 24; bold: true }
        }
    }

    Rectangle {
        id: background
        anchors.fill: albumlist

        MouseArea {
            anchors.fill: parent
            enabled: !container.hasPhotos
        }

        Image {
            id: noImg
            anchors { centerIn:  parent; verticalCenterOffset: -70 }
            source: application.getImageSource("no_img.png");
            visible: !container.hasPhotos
        }

        Text {
            anchors { top: noImg.bottom; topMargin: 10; horizontalCenter: parent.horizontalCenter }
            horizontalAlignment: Text.AlignHCenter
            text: "No Photos"
            color: "grey"
            visible: !container.hasPhotos
            font { pixelSize: 24; bold: true }
        }
    }

    SimpleList {
        id: albumlist
        visible: container.hasPhotos
        width: container.width
        anchors { top: leftTop.bottom; bottom: parent.bottom; left: parent.left }
        hasIcon: true
        singleLine: true
        indicator: true
        itemHeight: 80
        textFontSize: 24

        function footerHeight()
        {
            var h = 0;
            if(typeof(albumlist.model) === "object")
            {
                if(albumlist.height - albumlist.model.count*80 > 0)
                {
                    h = albumlist.height - albumlist.model.count*80;
                }
            }
            return h;
        }

        header: Rectangle {
            width: parent.width
            height: headLine.height * 2
            Image {
                id: headLine
                width: parent.width
                source: application.getImageSource("line_list_top.png")
            }
            Image {
                anchors.top: headLine.bottom
                width: parent.width
                source: application.getImageSource("line_list_bottom.png")
            }
        }

        footer: Rectangle {
            id: footers
            width: parent.width
            height: albumlist.footerHeight()
            Column {
                anchors.fill: parent
                spacing: 78
                Rectangle {
                    width: parent.width
                    height: 2
                }
                Repeater {
                    model: footers.height/80 + 1
                    Rectangle {
                        width: footers.width
                        height: footerLine.height * 2
                        Image {
                            id: footerLine
                            width: parent.width
                            source: application.getImageSource("line_list_top.png")
                        }
                        Image {
                            anchors.top: footerLine.bottom
                            width: parent.width
                            source: application.getImageSource("line_list_bottom.png")
                        }
                    }
                }
            }
        }

        onItemSelected: {
            container.contentX = container.width
        }
    }

    Image {
        id: rightTop
        y: 0
        x: container.width
        width: container.width
        source: application.getImageSource("bg_topzone.png");

        Button {
            anchors { left: parent.left; leftMargin: 5; verticalCenter: parent.verticalCenter }
            normalIcon: application.getImageSource("button_bg_01_normal.png")
            pressIcon: application.getImageSource("button_bg_01_press.png")
            text: "Photo al.."
            textColor: "white"
            onClicked: {
                container.contentX = 0
            }
        }

        Button {
            anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
            normalIcon: application.getImageSource("button_cancel_normal.png")
            pressIcon: application.getImageSource("button_cancel_press.png")
            text: "Cancel"
            textColor: "white"
            onClicked: {
                console.log("replyButton mouse area is clicked");
                viewmanager.back(viewmanager.slidePopdown);
            }
        }

        Text {
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            text: "Saved Photos"
            color: "#F0FFFF"
            font { pixelSize: 24; bold: true }
        }
    }

    PhotoGrid {
        id: photosgrid
        width: container.width
        x: container.width
        y: rightTop.height
        onPhotoSelected: {
            var view = viewmanager.getView(application.kNewTwitterView, false);
            view.picLocalUrl = url;
            view.hasPic = true;
            viewmanager.back(viewmanager.slidePopdown);
        }
    }

    Behavior on contentX {
            NumberAnimation { duration: 600 }
    }
}
