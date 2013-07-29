import QtQuick 1.0

Item {
    id: container

    property bool showList: false
    property alias model: listView.model
    property alias currentIndex: listView.currentIndex

    signal itemClicked(int index)

    height: showList ? titleContainer.height + listViewBg.height : titleContainer.height

    Component.onCompleted: {
        application.screen_nameChanged.connect(onScreenNameChanged);
    }

    function onScreenNameChanged()
    {
        console.log("title list onScreenNameChanged");
        console.log("in onScreenNameChanged application.screen_name is " + application.screen_name);
        title.text = application.screen_name
    }

    Item {
        id: titleContainer
        width: parent.width
        height: 60

        Item {
            id: textBg
            width: parent.width - titleArrow.width - titleArrow.anchors.leftMargin
            height: parent.height

            Text {
                id: title
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 30
                color: "white"
                elide: Text.ElideRight
            }
        }

        Image {
            id: titleArrow
            anchors {left: textBg.right; rightMargin: 10; verticalCenter: parent.verticalCenter}
            source: showList ? application.getImageSource("home_button_groupup.png") : application.getImageSource("home_button_groupdown.png")
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("titleClicked, list view should show/hide!");
                showList = !showList
            }
        }
    }

    //listView need a gray bg
    BorderImage {
        id: listViewBg
        source: application.getImageSource("group_bg.png")
        width: 212
        height: showList ? (60 * listView.count > 300 ? 300 : 60 * listView.count + 30) : 0
        border.left: 5; border.top: 15
        border.right: 5; border.bottom: 5
        visible: showList ? true : false
        anchors{top: titleContainer.bottom; topMargin: -5}

        ListView {
            id: listView
            width: parent.width
            anchors{top: parent.top; topMargin: 15; bottom: parent.bottom; bottomMargin: 20}
            model: viewModel
            clip: true

            onCurrentIndexChanged: {
                if(0 === currentIndex)
                {
                    console.log("current inde changed, current index is " + currentIndex);
                    title.text = application.screen_name
                }
                else
                {
                    title.text = listView.model.get(currentIndex).itemText
                }
            }

            delegate: Item {
                id: item
                width: parent.width
                height: 60

                Image {
                    id: name
                    source: application.getImageSource("group_selected.png")
                    anchors {fill: parent; margins: 3}
                    visible: ms.pressed || (currentIndex == index)
                }

                Text {
                    id: itemStr
                    text: itemText
                    width: parent.width - 10
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 21
                    color: ms.pressed ? "white" : "#40637D"
                    elide: Text.ElideRight
                }

                MouseArea {
                    id: ms
                    anchors.fill: parent
                    onClicked: {
                        console.log("title list clicked index is: " + index);
                        showList = !showList
                        if( listView.currentIndex == index)
                        {
                            console.log("title list clicked index is the same");
                            return;
                        }
                        listView.currentIndex = index;
                        container.itemClicked(index);
                    }
                }
            }
        }

            ListModel {
                id: viewModel
                ListElement {itemText: "All"; id_str: ""; needRemove: false}
                ListElement {itemText: "My Tweets"; id_str: ""; needRemove: false}
            }
        }
    }



