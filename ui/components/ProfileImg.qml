import QtQuick 1.0

BorderImage {
    id: container

    property alias profileSource: profile.source

    width: profile.width + 18
    height: profile.height + 18
    source: application.getImageSource("avatar_grid.png")
    border.left: 10; border.top: 10
    border.right: 10; border.bottom: 10

    Image {
        id: profile
        width: 48
        height: 48
        anchors{horizontalCenter: parent.horizontalCenter;verticalCenter: parent.verticalCenter; verticalCenterOffset: -1}
    }
}
