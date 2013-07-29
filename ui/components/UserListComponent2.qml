import QtQuick 1.0

Component {
    id : container

    Rectangle {
        id: userListViewItem
        width: parent.width
        height: iconArea.height

        MouseArea {
            id: itemMouseArea
            anchors.fill: parent
            onClicked: {
                userListViewItem.ListView.view.parent.itemSelected(index);
             }
        }

        // lines of top
        Image {
            id: topLine
            width: parent.width
            anchors {top: parent.top}
            source: application.getImageSource("line_list_top.png")
        }

        // lines of bottom
        Image {
            id: bottomLine
            width: parent.width
            anchors {bottom: parent.bottom}
            source: application.getImageSource("line_list_bottom.png")
        }

        //home item bg
        Image {
            id: bgHomeTtweets
            anchors {bottom: bottomLine.top}
            source: application.getImageSource("bg_home_tweets.png")
        }

        Image {
            id: highLightImage
            anchors.fill: parent
            source: application.getImageSource("list_press.png")
            visible:itemMouseArea.pressed
        }

        ProfileImg {
            id: iconArea
            anchors {left: parent.left; top: parent.top}
            profileSource: (true === default_profile_image) ? application.getImageSource("avatar_default.png") : profile_image_url
        }

        Text {
            id: userName
            text: name
            elide:Text.ElideRight
            color: "black"
            anchors {top:  iconArea.top; topMargin: 5; left: iconArea.right; leftMargin: 5;right: flipable.left}
            font { pixelSize: 22; bold: true}
        }

        Text {
            id: screenName
            text: "@" + screen_name
            elide:Text.ElideRight
            color: "gray"
            font {pixelSize: 16}
            anchors {left: userName.left; top: userName.bottom; topMargin: 2;right: flipable.left}
        }

        Flipable {
            id: flipable
            width: frontBtn.width
            height: frontBtn.height
            anchors {right: parent.right; rightMargin: 5; verticalCenter: parent.verticalCenter}

            front:
            Button {
                id : frontBtn
                anchors.fill: parent
                pressIcon: application.getImageSource("button_bg_follow_press.png");
                normalIcon: application.getImageSource("button_bg_follow_normal.png");
                text: "FOLLOW"
                textFontSize: 14
                textColor: "white"
                textFontBold: true
                onClicked: {
                    console.log("follow btn in more page clicked!");
                    userListViewItem.ListView.view.parent.follow(index,!following);
                }
            }

            back:
            Button {
                id : backBtn
                anchors.fill: parent
                pressIcon: application.getImageSource("button_bg_follow_press.png");
                normalIcon: application.getImageSource("button_bg_followed_normal.png");
                text: "FOLLOWING"
                textFontSize: 14
                textColor: "white"
                textFontBold: true
                onClicked: {
                    console.log("follow btn in user list components clicked!");
                    userListViewItem.ListView.view.parent.follow(index,!following);
                }
            }

            transform: Rotation {
                id: rotation
                origin.x: flipable.width/2
                origin.y: flipable.height/2
                axis.x: 0; axis.y: 1; axis.z: 0     // set axis.y to 1 to rotate around y-axis
                angle: 0    // the default angle
            }

            states: State {
                name: "back"
                PropertyChanges { target: rotation; angle: 180 }
                when: following === true
            }

            transitions: Transition {
                NumberAnimation { target: rotation; property: "angle"; duration: 1000 }
            }

        }

    }// Rectangle end
}// component end
