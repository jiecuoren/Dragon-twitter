import QtQuick 1.0
import "../components"
import "../components/keyboard"
import "../javascript/localdata.js" as LocalDB

Rectangle {
    id: container
    width: parent.width
    height: parent.height

    //every view should have this property
    property int viewId: application.kDraftListView
    property int deleteBehaviour: viewmanager.deleteOnBack

    property alias model : listview.model
    property bool viewActivated: false

    //every view should define below two functions
    function handleActivation()
    {
        state = '';
        viewActivated = true;
        console.log("draft list view handleActivation");
    }

    function handleDeactivation()
    {
        console.log("draft list view is deactivated");
    }

    function refreshList()
    {
        viewActivated = false;
        LocalDB.loadDraftInfo(model);
        console.log("draft list view refreshList");
    }

    Image {
        id: navigationBar
        anchors{ top: parent.top }
        source: application.getImageSource("bg_topzone.png");

        Button {
            pressIcon: application.getImageSource("button_bg_01_press.png");
            normalIcon: application.getImageSource("button_bg_01_normal.png");
            x: 10
            textFontSize: 18
            textColor: "white"
            text: "More"
            anchors {verticalCenter: parent.verticalCenter}

            onClicked: {
                console.log("left btn in user list clicked!");
                viewmanager.back(viewmanager.slideRight);
            }
        }

        Text {
            anchors.centerIn:  parent
            font {pixelSize: 30; family: "Catriel"; bold: true}
            verticalAlignment: Text.AlignVCenter
            color: "white"
            text: "Draft"
        }

        Button {
            id: rightBtn
            pressIcon: application.getImageSource("home_button_write_press.png");
            normalIcon: application.getImageSource("home_button_write_normal.png");
            anchors {verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 17}
            textFontSize: 18
            textColor: "white"
            onClicked: {
                viewmanager.activateViewById(application.kNewTwitterView, viewmanager.slidePopup);
                container.state = '';
            }
        }
    }// end of navigationBar

    ListView {
        id: listview
        width: parent.width
        anchors { top: navigationBar.bottom; bottom: toolBar.top; left: parent.left }
        clip: true
        focus: true
        highlightFollowsCurrentItem: true

        property bool normalMode : true
        function footerHeight()
        {
            var h = 0;
            if(typeof(container.model) === "object")
            {
                if(listview.height - container.model.count*80 > 0)
                {
                    h = listview.height - container.model.count*80;
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
            height: listview.footerHeight()
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

        delegate: Item {
            id: simpleListViewItem
            width: listview.width
            height: 80

            function textWidth()
            {
                var len = 0;
                if(picurl.length)
                {
                    len = listview.width - 15 - pic.width - arrow.width;
                }
                else
                {
                    len = listview.width - 25 - arrow.width;
                }

                if(showDelete && !listview.normalMode)
                {
                    len -= 65;
                }
                return len > 0 ? len : 0;
            }

            MouseArea {
                id: itemMouseArea
                anchors.fill: parent
                onClicked: {
                    if(listview.normalMode)
                    {
                        listview.currentIndex = index;
                        console.log("listview.currentIndex is " + listview.currentIndex);
                        var view = viewmanager.getView(application.kNewTwitterView, false);
                        view.title = title;
                        view.draftModifiedTime = datetime;
                        view.setContent(content);
                        view.hasPic = (picurl.length > 0);
                        view.enableLoc = enableloc;
                        view.tweetAddress = address;
                        view.picLocalUrl= picurl;
                        view.tweetType = view._editDraft;
                        viewmanager.activateView(view, viewmanager.slidePopup);
                    }
                    else if(showDelete)
                    {
                        container.model.setProperty(index, "showDelete", false);
                    }
                }
            }

            Rectangle {
                id: listitems
                x: listview.normalMode ? -(arrow.width+5) : 0
                height: parent.height
                width: parent.width + leftIndicator.width

                Behavior on x {
                    NumberAnimation { duration: 400 }
                }

                Rectangle {
                    id: leftIndicator
                    x: 0
                    width: arrow.width + 5
                    height: parent.height
                    Image {
                        anchors.centerIn: parent
                        source: application.getImageSource("delete-indicator.png")
                    }
                    Image {
                        anchors.centerIn: parent
                        source: application.getImageSource("delete-indicator-bar.png")
                        rotation: showDelete ? 90 : 0

                        Behavior on rotation {
                            NumberAnimation { duration: 200 }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            container.model.setProperty(index, "showDelete", !showDelete);
                        }
                    }
                }

                Rectangle {
                    color: "red"
                    radius: 5
                    width: 60
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    x: parent.width - arrow.width - 70
                    Text {
                        anchors.centerIn: parent
                        color: "white"
                        text: "Delete"
                        font { pixelSize :18; family: "Catriel"; bold: true }
                    }

                    Rectangle {
                        color: "white"
                        x: 0
                        y: 0
                        height: parent.height
                        width: showDelete && !listview.normalMode ? 0 : parent.width
                        Behavior on width {
                            NumberAnimation { duration: 200 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: !listview.normalMode && showDelete
                        onClicked: {
                            LocalDB.removeDraft(container.model.get(index).datetime);
                            container.model.remove(index);
                        }
                    }
                }

                Image {
                    x: picurl.length > 0 ? leftIndicator.width + 5 + pic.width : leftIndicator.width
                    width: picurl.length > 0 ? listview.width - pic.width : listview.width
                    height: parent.height
                    source: application.getImageSource("list_press.png")
                    visible: itemMouseArea.pressed && listview.normalMode
                }

                Image {
                    id: pic
                    x: leftIndicator.width + 3;
                    anchors {  top: parent.top;  topMargin: 1 }
                    width: simpleListViewItem.height - 6;
                    height: simpleListViewItem.height - 6
                    source: picurl
                    visible: picurl.length > 0
                    sourceSize { width: simpleListViewItem.height - 6;
                                 height: simpleListViewItem.height - 6 }
                }

                Text {
                    id: line1
                    x:  picurl.length > 0 ? 10 + pic.width + leftIndicator.width : 20 + leftIndicator.width
                    width: simpleListViewItem.textWidth()
                    anchors { verticalCenter: parent.verticalCenter; verticalCenterOffset: -(simpleListViewItem.height - font.pixelSize - 25 )/2 }
                    color: "black"
                    text: title === "New Tweet" ? "Tweet" : title
                    font { pixelSize : 24; family: "Catriel"; bold:true }
                    elide: Text.ElideRight
                }

                Text {
                    id: line2
                    x:  picurl.length > 0 ? 10 + pic.width + leftIndicator.width : 20 + leftIndicator.width
                    width: line1.width
                    anchors { top: line1.bottom; topMargin: 10 }
                    color: "gray"
                    text: content
                    font { pixelSize :18; family: "Catriel"; bold: false }
                    elide: Text.ElideRight
                }

                Image {
                    id: arrow
                    x: parent.width - arrow.width - 5
                    anchors { verticalCenter: parent.verticalCenter }
                    source: application.getImageSource("button_arrow_right.png")
                }
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
                width: parent.width
                anchors { bottom: parent.bottom }
                source: application.getImageSource("line_list_bottom.png")
            }

            ListView.onRemove: SequentialAnimation {
                    PropertyAction { target: simpleListViewItem; property: "ListView.delayRemove"; value: container.viewActivated }
                    NumberAnimation { target: listitems; property: "x"; to: -listitems.width; duration: 250; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: simpleListViewItem; property: "height"; to: 0; duration: 250; easing.type: Easing.InOutQuad }
                    PropertyAction { target: simpleListViewItem; property: "ListView.delayRemove"; value: false }
            }
        }
    }  //end of listview

    Image {
        id: toolBar
        anchors.bottom: parent.bottom
        source: application.getImageSource("bg_topzone.png");

        Button {
            id: editBtn
            pressIcon: application.getImageSource("button_cancel_press.png");
            normalIcon: application.getImageSource("button_cancel_normal.png");
            x: 10
            textFontSize: 18
            textColor: "white"
            text: "Edit"
            anchors { verticalCenter: parent.verticalCenter }

            Rectangle {
                anchors.fill: parent
                color: "grey"
                opacity: 0.4
                visible: (typeof(container.model) === "object" && container.model.count <= 0 && container.state !== "editMode")

                MouseArea {
                    anchors.fill: parent
                    enabled: parent.visible
                    onClicked: {
                        console.log("disable edit btn");
                    }
                }
            }

            onClicked: {
                if(container.state == "editMode")
                {
                    container.state = "";
                    for(var i = 0; i < container.model.count; i++)
                    {
                       container.model.setProperty(i, "showDelete", false);
                    }
                }
                else
                {
                    container.state = "editMode";
                }
            }
        }
    }// end of navigationBar

    states:  State {
        name: "editMode"
        PropertyChanges { target: listview; normalMode: false }
        PropertyChanges { target: editBtn; text: "Done" }
    }

}
