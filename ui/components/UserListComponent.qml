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
            elide:Text.ElideLeft
            color: "black"
            anchors {top:  iconArea.top; topMargin: 5; left: iconArea.right; leftMargin: 5}
            font { pixelSize: 22; bold: true}
        }

        Text {
            id: screenName
            text: "@" + screen_name
            elide:Text.ElideLeft
            color: "gray"
            font {pixelSize: 16}
            anchors {left: userName.left; top: userName.bottom; topMargin: 2 }
        }

        Image {
            anchors {right: parent.right; rightMargin: 5; verticalCenter: parent.verticalCenter}
            source: application.getImageSource("button_arrow_right.png")
        }

    }// Rectangle end
}// component end
