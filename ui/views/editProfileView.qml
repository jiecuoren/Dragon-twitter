import QtQuick 1.0
import "../apis"
import "../components"

Item {

    property int viewId: application.kEditProfileView
    property int deleteBehaviour : viewmanager.deleteOnBack

    width: parent.width
    height: parent.height

    Component.onCompleted: {
        console.log("edit profile view, onCompleted");

        dataModel.append({"key" : "name", "value": application.userInfo.name});

        if(typeof( application.userInfo.url) !== "undefined" )
        {
            dataModel.append({"key" : "url", "value" : application.userInfo.url});
        }
        else
        {
            dataModel.append({"key" : "url", "value" : ""});
        }

        if(typeof( application.userInfo.location) !== "undefined" )
        {
            dataModel.append({"key" : "location", "value" : application.userInfo.location});
        }
        else
        {
            dataModel.append({"key" : "location", "value" : ""});
        }

        if(typeof( application.userInfo.description) !== "undefined" )
        {
            dataModel.append({"key" : "description", "value" : application.userInfo.description});
        }
        else
        {
            dataModel.append({"key" : "description", "value" : ""});
        }
    }

    function handleActivation()
    {
        console.log("edit profile view is activated");
    }

    function handleDeactivation()
    {
        console.log("edit profile view is deactivated");
    }

    ListModel {
        id: dataModel
    }

    //layouts
    Image {
        id: navigationBar
        source: application.getImageSource("bg_topzone.png")
        anchors.top: parent.top

        Button {
            anchors {verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 15}

            normalIcon: application.getImageSource("write_button_close_normal.png")
            pressIcon: application.getImageSource("write_button_close_press.png")

            onClicked: {
                viewmanager.back(viewmanager.slideRight);
            }
        }

        Button {
            anchors {verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 15}

            normalIcon: application.getImageSource("write_button_send_normal.png")
            pressIcon: application.getImageSource("write_button_send_press.png")

            onClicked: {
                console.log("edit profile view, send btn clicked");
                editApi.editProfile(dataModel)
            }
        }

        Text {
            anchors.centerIn: parent
            text: "Edit Profile"
            color: "#F0FFFF"
            font.pixelSize: 30
        }
    }

    SimpleButton {
        id: profileImageArea
        anchors {horizontalCenter: parent.horizontalCenter; top: navigationBar.bottom; topMargin: 10}
        enabled: false
        normalIcon: application.getImageSource("button_single_normal.png")
        pressIcon: application.getImageSource("button_single_press.png")

        ProfileImg {
            id: userIcon
            anchors {left: parent.left; leftMargin: 3; verticalCenter: parent.verticalCenter}
            profileSource: application.userInfo.profile_image_url
        }

        Text {
            anchors {verticalCenter: parent.verticalCenter; left: userIcon.right; leftMargin: 5}
            text: "Profile Image"
            font {bold: true; pixelSize: 24}
        }
    }

    ListView {
        id: listView
        anchors {left: parent.left; right: parent.right; top: profileImageArea.bottom;
                 topMargin: 16; bottom: parent.bottom}
        spacing: 1
        clip: true

        model: dataModel
        delegate: SimpleButton {
            id: mainBtn
            x: (ListView.view.width - width) / 2
            normalIcon: getNormalIcon()
            pressIcon: getPressIcon()
            enabled: false
            function getPressIcon()
            {
                if (0 === index)
                {
                    if(mainBtn.ListView.view.count == 1)
                    {
                        return application.getImageSource("button_single_press.png")
                    }
                    return application.getImageSource("list_press_top.png")
                }
                else if ( mainBtn.ListView.view.count - 1 == index )
                {
                    return application.getImageSource("list_press_bottom.png")
                }
                else
                {
                    return application.getImageSource("list_press_mid.png")
                }
            }

            function getNormalIcon()
            {
                if (0 === index)
                {
                    if(mainBtn.ListView.view.count == 1)
                    {
                        return application.getImageSource("button_single_normal.png")
                    }
                    return application.getImageSource("list_bg_top.png")
                }
                else if ( mainBtn.ListView.view.count -1 == index )
                {
                    return application.getImageSource("list_bg_bottom.png")
                }
                else
                {
                    return application.getImageSource("list_bg_mid.png")
                }
            }

            function getMaxInputLength()
            {
                console.log("edit profile view,getMaxInputLength ");
                //default value is 20, name's max length is 20
                var ret = 20;

                if(1 == index)
                {
                    ret = 100 ;
                }
                else if(2 == index)
                {
                    ret = 30
                }
                else if(3 == index)
                {
                    ret = 150
                }

                console.log("ret is " + ret);

                return ret;
            }

            Text {
                id: keyText
                width: 100
                text: key
                anchors {left: parent.left; verticalCenter: parent.verticalCenter}
                horizontalAlignment: Text.AlignRight
                color: "lightblue"
            }

            TextInput {
                id: valueText
                width: 180
                text: value
                horizontalAlignment: Text.AlignLeft
                clip: true
                anchors {left: keyText.right; leftMargin: 6; verticalCenter: parent.verticalCenter}
                maximumLength: getMaxInputLength()
                onTextChanged: {
                    dataModel.set(index, {"value": text});
                }
            }

            Image {
                id: rightArrow
                source: application.getImageSource("button_arrow_right.png")
                anchors {verticalCenter: parent.verticalCenter; right: parent.right; }
            }

            onClicked: {
                console.log("clicked on item in edit profile");

                if (!valueText.activeFocus) {
                     valueText.forceActiveFocus();
                     valueText.openSoftwareInputPanel();
                 } else {
                     valueText.focus = false;
                 }
            }
        }
    }

    ApiEditProfile {
        id: editApi

        onDataReceived: {
            console.log("dataReceived in edit profile view")
            application.userInfo = userObject;
            var view = viewmanager.getView(kUserProfileView, false);
            view.resetUserProfile();
            note.source = application.getImageSource("rightmark.png");
            note.promptInfo = "Profile Changed!"
            note.visible = true
        }

        onErrorOccured: {
            note.source = application.getImageSource("wrongmark.png");
            note.promptInfo = "Edit profile failed!"
            note.visible = true
        }
    }

    Note {
        id: note
        anchors.centerIn: parent
        visible: false
    }
}
