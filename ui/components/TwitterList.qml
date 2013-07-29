import QtQuick 1.0

Item {
    id: container

    //published properties
    property bool reachEnd: false  //if no more data can be loaded, set it to true
    property bool supportRefresh: true  //if true, pull down the list to refresh
    property bool isRefreshing: false   //after loading data, set it to false

    property alias delegate: theListView.delegate
    property alias model: theListView.model

    property alias twitterListView : theListView

    signal itemSelected(int index)
    signal loadMoreTriggered
    signal refreshTriggered

    signal listMoveStarted
    signal popUpMenuTriggered(int index)
    signal mouseYPosChanged(int index)

    // A bug of listview
    // There is no guarantee that the origin will be 0
    // if the delegate size is not consistent.
    property real contentYOffset: 0
    function updateLastUpdateTime()
    {
        lastUpdateTime.text = "Last update: " + Qt.formatDateTime(new Date(), "MM/dd/yy h:mm AP")
    }

    function checkModelData()
    {
        console.log("twitter list, checkModelData");
        if(0 === model.count)
        {
            noDataText.visible = true;
        }
        else
        {
            noDataText.visible = false
        }
    }

    function setViewAtBeginning()
    {
        theListView.positionViewAtIndex(0, ListView.Beginning);
        contentYOffset = theListView.contentY;
    }

    function realContentY(value)
    {
        return value - contentYOffset;
    }

    clip: true

    Component {
        id: footerComponent

        Image {
            id: footerImg
            source: (container.reachEnd) ? application.getImageSource("dot.png") : ""
            visible: theListView.count === 0 ? false : true
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Item {
        id: updateArea
        height: 59
        anchors {left: parent.left; right: parent.right; top: parent.top}
        visible: (theListView.count !== 0) && supportRefresh && !isRefreshing

        Image {
            id: updateImg
            source: application.getImageSource("arrow.png")
            anchors {verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 30}
            rotation: 180

            Behavior on rotation {
                NumberAnimation { duration: 300 }
            }
        }

        Text {
            id: updateText
            color: "black"
            font.pixelSize: 20
            text: "Pull down to refresh..."
            anchors {top: parent.top; topMargin: 4; left: updateImg.right; leftMargin: 40}
        }

        Text {
            id: lastUpdateTime
            color: "black"
            height: 24
            font.pixelSize: 20
            anchors {left: updateImg.right; leftMargin: 20; bottom: parent.bottom; bottomMargin: 4}
        }
    }

    ListView {
        id: theListView
        anchors.fill: parent
        clip: true
        footer: footerComponent
        currentIndex: -1
        highlightFollowsCurrentItem: false

        property bool updateEnabled: false
        property real minimumContentY: 0

        onMovementStarted: {
            console.log("onMovementStarted");
            container.listMoveStarted();
        }

        onMovementEnded: {
            console.log("onMovementEnded");

            if (minimumContentY < -updateArea.height)
            {
                container.isRefreshing = true;
                container.refreshTriggered();
                minimumContentY = 0.0;
                return;
            }

            if (theListView.atYEnd)
            {
                if (reachEnd || isRefreshing || 0 === model.count)
                {
                    return;
                }

                container.isRefreshing = true
                container.loadMoreTriggered();
            }
        }// end movement end

        onContentYChanged: {
           if (!supportRefresh || isRefreshing)
           {
               return;
           }

            if (minimumContentY > realContentY(contentY))
            {
                minimumContentY = realContentY(contentY);
            }

            if (-updateArea.height > realContentY(contentY))
            {
                if (!updateEnabled)
                {
                    updateText.text = "Release to refresh..."
                    updateImg.rotation = 0;
                    updateEnabled = true
                }
            }
            else
            {
                if (updateEnabled)
                {
                    updateText.text = "Pull down to refresh..."
                    updateImg.rotation = 180;
                    updateEnabled = false
                }
            }
        } //end of contentY changed
    }  //end of listview

    Text {
        id: noDataText
        text: "No items"
        color: "gray"
        font{pixelSize: 15; bold: true}
        x: 20
        y: 20
        visible: false
    }

    Image {
        id: shadow
        source: application.getImageSource("shadow_list.png")
        y: (theListView.count > 0) ? -realContentY(theListView.contentY) : 0
        visible: y >= 0
    }

    Image {
        id: loadingImg
        source: application.getImageSource("loading_bottom_" + String(counter%4+1) + ".png")
        anchors {horizontalCenter: parent.horizontalCenter; bottom: parent.bottom}
        visible: isRefreshing
        property int counter: 0

        Timer {
            id: timer
            interval: 100
            running: isRefreshing
            repeat: true

            onTriggered: {
                ++loadingImg.counter;
            }
        }
    }

} // end of file
