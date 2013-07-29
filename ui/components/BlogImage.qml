import QtQuick 1.0

Image {
    id: blogImage

    signal downloadingStarted

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        onClicked: {
            blogImage.downloadingStarted()
        }
    }

}
