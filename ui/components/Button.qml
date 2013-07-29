import QtQuick 1.0

Item {
    id: button
    width: buttonIcon.width
    height: buttonIcon.height

    property alias enabled: ms.enabled
    property alias text: btnText.text
    property alias textFontFamily: btnText.font.family
    property alias textFontSize: btnText.font.pixelSize
    property alias textFontBold: btnText.font.bold
    property color textColor: "black"
    property color pressTextColor
    property int textX: ( buttonIcon.width - btnText.width )/2
    property int textY: ( buttonIcon.height - btnText.height ) /2

    property url pressIcon
    property url normalIcon
    property url disableIcon
    
    property variant action

    signal clicked

    onTextChanged: {

        if ( btnText.width > buttonIcon.width )
        {
            btnText.x = 10;
            btnText.width = buttonIcon.width - btnText.x;
            btnText.elide = Text.ElideRight;
        }
    }

    onNormalIconChanged: {
        buttonIcon.source = normalIcon;
    }

    Image {
        id: buttonIcon
        source: normalIcon
        anchors.centerIn: parent
    }

    Text {
        id: btnText
        x: textX
        y: textY
        color: button.textColor
        font.pixelSize: 18
    }

    MouseArea {
        id: ms
        anchors.fill: parent
        onPressed: {
            buttonIcon.source = pressIcon;
            if(pressTextColor.length > 0) {
                btnText.color = pressTextColor;
            }
        }

        onPositionChanged: {
            if (containsMouse)
            {
                buttonIcon.source = pressIcon;
                if(pressTextColor.length > 0) {
                    btnText.color = pressTextColor;
                }
            }
            else
            {
                buttonIcon.source = normalIcon;
                btnText.color = button.textColor;
            }
        }

        onReleased: {
            buttonIcon.source = normalIcon;
            btnText.color = button.textColor;
            if (containsMouse)
            {
                console.log("mouse is within mousearea, emit clicked()");
                if ( action !== undefined )
                {
                    action.trigger()
                }
                else
                {
                    button.clicked();
                }
            }
        }
    }

    states: [
            State {
                name: "disabled"
                when: !enabled
                PropertyChanges {target: buttonIcon; source: disableIcon}
                PropertyChanges {target: ms; enabled: false}
            }
            ,
            State {
                name: "enable"
                when: enabled
                PropertyChanges {target: buttonIcon; source: normalIcon}
                PropertyChanges {target: ms; enabled: true}
            }
        ]
}
