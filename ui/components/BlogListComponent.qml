import QtQuick 1.0

Component {
    id : blogListDelegate

    Rectangle {
        id: blogListViewItem
        property int mouseStartX: 0
        property int mouseStartY: 0
        property bool sendSignal: false

        width: parent.width
        height: (weiBoText.height + userName.height > userIcon.height) ?
                    weiBoText.height + userName.height + topLine.height + bottomLine.height + retweetedIcon.height + 18:
                    userIcon.height + topLine.height + bottomLine.height + retweetedIcon.height + 15

        MouseArea {
            id: itemMouseArea
            anchors.fill: parent

            onReleased: {
                console.log("onReleased");
                if (containsMouse)
                {
                    if ( !blogListViewItem.sendSignal )
                    {
                        blogListViewItem.ListView.view.parent.itemSelected(index);
                    }
                }
            }

            onPressed: {
                console.log("onPressed");
                blogListViewItem.sendSignal = false;
                blogListViewItem.mouseStartX = mouseX;
                blogListViewItem.mouseStartY = mouseY;
            }

            onMousePositionChanged: {
                var yMove = Math.abs( mouseY - blogListViewItem.mouseStartY );
                var xMove = Math.abs ( mouseX - blogListViewItem.mouseStartX );

                if ( xMove > 15 && yMove <=15 &&  blogListViewItem.sendSignal === false )
                {
                    blogListViewItem.ListView.view.parent.popUpMenuTriggered( index );
                    blogListViewItem.sendSignal = true;
                }
                else if ( yMove > 15 &&  blogListViewItem.sendSignal === false)
                {
                    blogListViewItem.ListView.view.parent.mouseYPosChanged( index );
                }
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
            id: userIcon
            anchors {left: parent.left; top: topLine.bottom; leftMargin: 3; topMargin: 1}
            profileSource: (true === default_profile_image) ? application.getImageSource("avatar_default.png") : profile_image_url
        }

        Text {
            id: userName
            text: screen_name
            color: "black"
            font {pixelSize: 18; bold: true}
            anchors {left:  userIcon.right; leftMargin: 5; top: userIcon.top}
        }

        Text {
            id: createdTime
            text: created_at_short
            color: "gray"
            font {pixelSize: 15; bold: true}
            anchors {right:  favorited ? favoriteIndicator.left : parent.right;
                     rightMargin: favorited ? 4 :  10;
                     top: userName.top}
        }

        Image {
            id: mediaIndicator
            source: (media.count > 0) ? application.getImageSource("tinyicon_img.png") : ""
            anchors {right: createdTime.left; rightMargin: 4; top: userName.top}
        }

        Image {
            id: favoriteIndicator
            source: favorited ? application.getImageSource("fav_mark.png") : ""
            width: 30
            height: 30
            anchors {right: parent.right; rightMargin: 2}
        }

        Text {
            id: weiBoText
            anchors {top: userName.bottom; topMargin: 5; left: userName.left; right: parent.right; rightMargin: 5}
            wrapMode: Text.WordWrap
            text: mini_blog_content
            color:"#1E1E1E"
            font.pixelSize: 17
        }

        Image {
            id: retweetedIcon
            width: retweeted_by === "" ? 0 :  sourceSize.width
            height: retweeted_by === "" ? 0 : sourceSize.height
            source: application.getImageSource("tinyicon_retweet.png")
            anchors{top: weiBoText.bottom; topMargin: 5; left:  weiBoText.left }
        }

        Text {
            id: retweetedBy
            anchors {left: retweetedIcon.right; leftMargin: 5; top: retweetedIcon.top }
            wrapMode: Text.WordWrap
            text: retweeted_by === "" ? "" :  "by " + retweeted_by
            color:"gray"
            font{pixelSize: 12; bold: true}
        }
    }// Rectangle end
}// component end
