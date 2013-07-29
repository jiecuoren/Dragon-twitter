import QtQuick 1.0

Item {
    property bool initValue: true

    signal valueChanged(bool newValue)

    width: 94
    height: onOffImage.sourceSize.height
    clip: true

    Image {
        id: onOffImage
        source: application.getImageSource("iphone-toggle.png")
        x: initValue ? 0 : -53

        Behavior on x {
            NumberAnimation {id: theAnimation; duration: 500}
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (theAnimation.running)
            {
                return;
            }

            if (onOffImage.x === 0)
            {
                onOffImage.x = -53;
                valueChanged(false);
            }
            else
            {
                onOffImage.x = 0;
                valueChanged(true);
            }
        }
    }
}
