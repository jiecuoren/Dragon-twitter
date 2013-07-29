import QtQuick 1.0

Rectangle {
    id: container

    property int column : 3
    property alias model: gridview.model
    signal photoSelected(string url)

    function cellWidth()
    {
        if(column > 0)
            return Math.floor(container.width/column);
        return container.width;
    }

    width: parent.width
    height: parent.height

    Component {
        id: photosDelegate
        Item {
            width: gridview.cellWidth
            height: gridview.cellHeight
            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: 5
                border.color: "gray"
                border.width: 2
                smooth : true
                color: "yellow"
                clip: true
                Image {
                    source: thumbnail
                    anchors.fill: parent
                    fillMode: Image.Stretch
                    asynchronous: true
                    sourceSize.width: gridview.cellWidth
                    sourceSize.height: gridview.cellHeight
                    Rectangle {
                        anchors.fill: parent
                        color: "steelblue"
                        opacity: imageArea.pressed ? 0.4 : 0.0
                    }
                    MouseArea {
                        id: imageArea
                        anchors.fill: parent
                        onClicked: {
                            container.photoSelected(url);
                        }
                    }
                }
            }
        }
    }

    GridView {
        id: gridview
        anchors.fill: parent
        interactive: true
        cellWidth: container.cellWidth()
        cellHeight: container.cellWidth()
        cacheBuffer: container.cellWidth() * 2
        delegate: photosDelegate
        clip: true
    }
}
