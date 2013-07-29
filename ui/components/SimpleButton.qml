import QtQuick 1.0

Item {
    id: button
    width: buttonIcon.width
    height: buttonIcon.height

    property alias enabled: ms.enabled
    property alias text: btnText.text
    property alias textFontSize: btnText.font.pixelSize
    property alias textColor: btnText.color
    property int textX: (buttonIcon.width-btnText.width)/2
    property int textY: (buttonIcon.height-btnText.height) /2
    property alias textWidth: btnText.width

    property url pressIcon
    property url normalIcon

    signal clicked

    Image {
        id: buttonIcon
        source: ms.pressed ? pressIcon : normalIcon
        anchors.centerIn: parent
    }

    Text {
        id: btnText
        elide: Text.ElideRight
        x: textX
        y: textY
        color: "black"
        font.pixelSize: 22
    }

    MouseArea {
        id: ms
        anchors.fill: parent
        onClicked: {
            console.log("simple button clicked");
            button.clicked();
        }
    }

}
