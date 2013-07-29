import QtQuick 1.0

MouseArea {
    id: container

    property alias promptInfo: prompt.text

    width: parent.width
    height: parent.height

    Image {
        id: bgImg
        source: application.getImageSource("loading_bg_center.png")
        anchors.centerIn: parent

        Image {
            id: loadingimg

            anchors.centerIn: parent
            source: application.getImageSource("loading_white_01.png")

            NumberAnimation  on rotation {
                running: container.visible; from: 0; to: 360; loops: Animation.Infinite; duration: 4800
            }
        }

        Text {
            id : prompt
            color: "white"
            font.pixelSize: 16
            anchors {top: loadingimg.bottom; horizontalCenter: bgImg.horizontalCenter}
            opacity: 1.0
            text: ""
        }

    }

}
