import QtQuick 1.0
import TwitterEngine 1.0
import "../components"
import "../views"

Item {
    id: container

    property bool topBarShow: true
    property alias source: originImage.source

    property url addressUrl: ''

    //every view should have this property
    property int viewId: application.kShowOriginalImageView
    property int deleteBehaviour: viewmanager.deleteOnBack

    //every view should define below two functions
    function handleActivation()
    {
        console.log("show original image view  is activated");

        if (originImage.status == Image.Ready ||originImage.status == Image.Error)
        {
            loadingdlg.visible = false;
        }
        else
        {
            loadingdlg.visible = true;
        }

    }

    function handleDeactivation()
    {
        console.log("show original image view  is deactivated");
        loadingdlg.visible = false;
    }

    function handleCommand( index )
    {
        var view;
        var mail_link = container.source;
        switch ( index )
        {
        case 0:
            Qt.openUrlExternally("mailto:" + "?subject=" +"mail link"+ "&body=" + mail_link);
            break;
        case 1:
            Qt.openUrlExternally( container.addressUrl );
            break;
        case 2:
            imgSaver.saveImage(originImage);
            break;
        default:
            break;
        }
    }

    width: parent.width
    height: parent.height

    Image {
        id: readBg
        anchors.fill: parent
        source: application.getImageSource("bg_paper.png")
    }

    Image {
        id : bgTop
        z: 1
        source: application.getImageSource("img_headbar.png")
        Button {
            id: topButton
            normalIcon: application.getImageSource("button_bg_01_normal.png")
            pressIcon: application.getImageSource("button_bg_01_press.png")
            textFontSize: 21
            textFontFamily: "Catriel"
            textFontBold: true
            textColor: "#F0FFFF"
            text : "Tweet"
            anchors {
                left: bgTop.left
                leftMargin: 20
                verticalCenter: parent.verticalCenter
            }

            onClicked: {
                console.log("left btn in home page clicked!");
                viewmanager.back( viewmanager.slideRight );
            }
        }
    }

    Flickable {
        id : flick
        width: parent.width
        clip: true
        anchors {
            top: parent.top
            bottom:parent.bottom
        }
        contentWidth: originImage.width
        contentHeight: originImage.height

        Image {
            id: originImage
            onStatusChanged: {
                if (originImage.status == Image.Ready ||originImage.status == Image.Error)
                {
                    loadingdlg.visible = false;
                    originImage.x = flick.width >= originImage.width ? (flick.width - originImage.width)/2 : 0
                    originImage.y = flick.height >= originImage.height ? (flick.height - originImage.height)/2 : 0
                    flick.contentX = originImage.width > flick.width ? (originImage.width - flick.width)/2 : 0
                    flick.contentY = originImage.height > flick.height ? (originImage.height - flick.height)/2 : 0
                }
            }

        }

        MouseArea {
            id: picmouseArea
            width: flick.width > flick.contentWidth ? flick.width : flick.contentWidth
            height: flick.height > flick.contentHeight ? flick.height : flick.contentHeight
            x:0
            y:0
            onReleased: {
                console.log("picture mouse area is clicked");
                container.topBarShow = !container.topBarShow;
            }
        }
    }

    Image {
        id : bgBottom
        source: application.getImageSource("img_headbar.png")
        y: parent.height - bgBottom.height
        z: 1
        Button {
            id: bottomButton
            normalIcon: application.getImageSource("button_export_normal.png")
            pressIcon: application.getImageSource("button_export_press.png")
            anchors {
                right: parent.right
                rightMargin: 20
                verticalCenter: parent.verticalCenter
            }
            onClicked: {
                    console.log("menu mouse area is clicked");
                    actionSheetDialog.active();
            }
        }

    }

    LoadingDlg {
        id: loadingdlg
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
    }

    ImageSaver {
        id: imgSaver

        onSaveReturned: {
            if(aRetValue)
            {
                note.source = application.getImageSource("rightmark.png");
                note.promptInfo = "Image saved!"
            }
            else
            {
                note.source = application.getImageSource("wrongmark.png");
                note.promptInfo = "Image save failed!"
            }
            note.visible = true
        }

        Component.onCompleted: {
            actionSheetModel.append({"displayText": "Save image to " + imgSaver.imagePath,
                                        "destructive": false});
        }
    }

    ListModel {
        id :actionSheetModel

        ListElement {
            displayText:"Mail Link"
            destructive: false
        }

        ListElement {
            displayText:"View on t.co"
            destructive: false
        }
    }

    ActionSheet {
        id :actionSheetDialog
        model: actionSheetModel
        onItemSelected: {
            console.log("actionSheetDialog...",index);
            handleCommand( index );
            console.log("actionSheetDialog...");
        }
    }

    Note {
        id: note
        anchors.centerIn: parent
        visible: false
    }

    states: [
        State {
            name: "topBarShow"
            when: container.topBarShow === true
        },
        State {
            name: "topBarHide"
            when: container.topBarShow === false
        }

    ]

    transitions:[
        Transition {
            from: "topBarHide"
            to: "topBarShow"
            NumberAnimation { target: bgTop; property: "y"; from:-( bgTop.height ); to:0; easing.type: Easing.InOutQuad; duration: 200 }
            NumberAnimation { target: bgBottom; property: "y"; from:bgBottom.parent.height;to:bgBottom.parent.height-bgBottom.height;easing.type: Easing.InOutQuad; duration: 200 }
        },
        Transition {
            from: "topBarShow"
            to: "topBarHide"
            NumberAnimation { target: bgTop; property: "y"; from:0; to:-( bgTop.height );easing.type: Easing.InOutQuad; duration: 200 }
            NumberAnimation { target: bgBottom; property: "y"; from: bgBottom.parent.height - bgBottom.height;to:bgBottom.parent.height;easing.type: Easing.InOutQuad; duration: 200 }
        }

    ]
}
