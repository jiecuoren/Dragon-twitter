import QtQuick 1.0

Item {
    id: container

    property alias promptInfo: prompt.text
    property alias source: loadingimg.source

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
        }

        Text {
            id : prompt
            color: "white"
            font.pixelSize: 16
            anchors {top: loadingimg.bottom; horizontalCenter: bgImg.horizontalCenter}
            opacity: 1.0
        }

    }

    Timer {
        id: timer1
        interval: 2000
        running: container.visible == true
        repeat: false
        onTriggered: {
            console.log("note start to disappear");
            container.visible = false;
        }
    }

}
