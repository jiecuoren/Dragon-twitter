import QtQuick 1.0

Item {
    id: container
    width: parent.width
    height: isCollaps ? titleBtn.height : titleBtn.height + listView.height

    signal itemSelected(int index)
    signal footerClicked
    signal titleBtnClicked

    property alias titleText: titleBtn.text
    property alias model: listView.model
    property string footerText: ""
    property bool footerVisible: false
    // collaps flag. default is true
    property bool isCollaps: true

    SimpleButton {
        id: titleBtn
        anchors {top: parent.top; horizontalCenter: parent.horizontalCenter}
        pressIcon: isCollaps ? application.getImageSource("button_single_press.png") : application.getImageSource("list_press_top.png");
        normalIcon: isCollaps ? application.getImageSource("button_single_normal.png") : application.getImageSource("list_bg_top.png");
        textColor: isCollaps ? "black" : "blue"

        Image {
            id: titleArrow
            anchors{right: parent.right; rightMargin: 5; verticalCenter: parent.verticalCenter}
            source: application.getImageSource("button_arrow_down.png")
            rotation: isCollaps ? 0 : 180

            Behavior on rotation {
                NumberAnimation { duration: 400 }
            }
        }

        onClicked: {
            console.log("title btn clicked");
            if(listView.count == 0)
            {
                console.log("Clicked on title button");
                container.titleBtnClicked();
            }
            else
            {
                isCollaps = !isCollaps;
            }
        }
    }

    Component {
        id: listDelegate

        SimpleButton {
            id: mainBtn
            pressIcon: (index == (listView.count-1) && container.footerText === "") ? application.getImageSource("list_press_bottom.png") : application.getImageSource("list_press_mid.png")
            normalIcon: (index == (listView.count-1) && container.footerText === "") ? application.getImageSource("list_bg_bottom.png") : application.getImageSource("list_bg_mid.png")
            textWidth: 280
            text: full_name
            textColor: "black"
            textX: 10
            onClicked: {
                console.log("clicked at index "+ index);
                container.itemSelected(index);
            }

            Image {
                anchors {right: parent.right; rightMargin: 5; verticalCenter: parent.verticalCenter}
                source:application.getImageSource("button_arrow_right.png")
            }

        } // end of simple btn
    }// end of component

    ListView{
        id: listView
        width: titleBtn.width
        height: isCollaps ? 0 : 61 * (count+1*container.footerVisible)
        opacity: isCollaps ? 0 : 1
        spacing: 1
        interactive: false
        anchors {top: titleBtn.bottom; topMargin: 1; left: titleBtn.left}
        delegate: listDelegate
        clip: true
        footer: Item {
            width: footerBtn.width
            height: footerBtn.height + 1

            SimpleButton {
                id: footerBtn
                pressIcon: application.getImageSource("list_press_bottom.png")
                normalIcon: application.getImageSource("list_bg_bottom.png")
                text: container.footerText
                textColor: "blue"
                visible: (container.footerVisible) && !container.isCollaps
                height: visible ? 60 :0
                anchors{bottom: parent.bottom; horizontalCenter: parent.horizontalCenter}
                onClicked: {
                    console.log("footer Clicked");
                    container.footerClicked();
                }
            }
        }


        Behavior on height {
            NumberAnimation { duration: 400 }
        }

        Behavior on opacity {
            NumberAnimation { duration: 400 }
        }
    }



}
