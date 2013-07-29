import QtQuick 1.0

Item {
    id:container

    signal itemSelected(int index)
    property alias model: simpleListView.model
    property alias listView: simpleListView
    property alias header: simpleListView.header
    property alias footer: simpleListView.footer
    property color textColor: "#403F41"
    property int textFontSize: 21
    property int itemHeight: 50
    property bool hasIcon : false
    property bool singleLine : true
    property bool indicator : false

    ListView {
        id: simpleListView
        width: parent.width
        height: parent.height
        clip: true
        focus: true
        highlightFollowsCurrentItem: true
        anchors { verticalCenter:parent.verticalCenter }

        delegate: Item {
            id: simpleListViewItem
            width: simpleListView.width
            height: container.itemHeight

            function getProfileIcon()
            {
                if(icon_url.length > 0)
                    return icon_url;
                return application.getImageSource("avatar_default.png");
            }

            MouseArea {
                id: itemMouseArea
                anchors.fill: parent
                onClicked: {
                    container.itemSelected(index)
                    simpleListView.currentIndex = index
                    console.log("simpleListView.currentIndex is " + simpleListView.currentIndex);
                 }
            }

            Image {
                id: highLightListImage
                x: container.hasIcon ? 5 + userIcon.width : 0
                width: container.hasIcon ? parent.width - userIcon.width : parent.width
                height: parent.height
                source: application.getImageSource("list_press.png")
                visible: itemMouseArea.pressed
            }

            BorderImage {
                id: userIcon
                visible: container.hasIcon
                opacity: container.hasIcon ? 1.0 : 0.0
                source: application.getImageSource("avatar_grid.png")
                width: container.itemHeight; height: container.itemHeight
                border { left: 3; top: 3; right: 3; bottom: 3 }
                anchors {left: parent.left; top: topLine.bottom; leftMargin: 3; topMargin: 1}
                Image {
                    anchors { centerIn: parent ; verticalCenterOffset: -3 }
                    width: parent.width - 6
                    height: parent.height - 6
                    source: container.hasIcon ? getProfileIcon() : ""
                    sourceSize { width: parent.width - 6; height: parent.height - 6 }
                }
            }

            Text {
                id: line1
                x:  container.hasIcon ? 10 + userIcon.width : 20
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: container.singleLine ? 0: -(container.itemHeight - container.textFontSize - 5 )/2
                color: container.textColor
                text: line1Text
                font { pixelSize :container.textFontSize; family: "Catriel"; bold:true }
                elide: Text.ElideRight
            }

            Text {
                id: line2
                anchors { left: line1.left; top: line1.bottom }
                color: "gray"
                text: line2Text
                visible: !container.singleLine
                font { pixelSize :container.textFontSize - 3; family: "Catriel"; bold: false }
                elide: Text.ElideRight
            }

            Image {
                anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 5 }
                source: container.indicator ? application.getImageSource("button_arrow_right.png") : ""
            }

            // lines of top
            Image {
                id: topLine
                width: parent.width
                anchors { top: parent.top }
                source: application.getImageSource("line_list_top.png")
            }

            // lines of bottom
            Image {
                id: bottomLine
                width: parent.width
                anchors { bottom: parent.bottom }
                source: application.getImageSource("line_list_bottom.png")
            }
        }
    }  //end of listview
}
