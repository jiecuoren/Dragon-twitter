import QtQuick 1.0

Item {

    id : container

    anchors.fill: parent

    property alias text: menuTextbutton.text
    property alias model: actionSheetRepeater.model

    signal itemSelected( int index )

    function active()
    {
        console.log("container.state",container.state);
        actionSheetItem.state = 'show';
    }

    function deactive()
    {
        actionSheetItem.state = '';

    }

    z:3

    MouseArea {
        anchors.fill: other
        enabled: actionSheetItem.state == 'show'
    }

    Rectangle {
        id : other
        width: parent.width
        height: parent.height
        y: 0
        opacity: actionSheetItem.state == 'show' ? 0.4 : 0
    }

    Item {
        id : actionSheetItem
        y: parent.height
        width: parent.width
        height: ( menuTextbutton.text === '' )? (menuCancelbutton.height + actionSheetColum.height + 10 + 20 + 20 )
                                             :(menuCancelbutton.height + actionSheetColum.height + 10 + 20 + 20 + menuTextbutton.height + 20)

        Image {
            id: menuBackGroundImage
            source: application.getImageSource("bg_up.png")
            anchors.fill: parent
        }

        Text {
            id: menuTextbutton
            width: parent.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            anchors {
                      bottom : actionSheetColum.top
                      bottomMargin:20
                      horizontalCenter: parent.horizontalCenter
            }
            font { pixelSize: 21; family: "Catriel"; bold:true }
            color:"#F9F9F9"
            visible: menuTextbutton.text !== ''
        }

        Component {
            id : dialogDelete
            Item {
                id : buttonItem
                width: actionSheetColum.width
                height: menuCancelbutton.height + 20
                Button {
                    id: buttonId
                    text: displayText
                    textFontSize: 21
                    textFontFamily: "Catriel"
                    textFontBold: true
                    textColor: "#403f41"
                    anchors { horizontalCenter: parent.horizontalCenter }
                    normalIcon:( destructive === false) ? application.getImageSource("button_up_normal_1.png")
                                 : application.getImageSource("button_up_normal_3.png")
                    pressIcon: ( destructive === false) ? application.getImageSource("button_up_press.png")
                                 : application.getImageSource("button_up_press_3.png")
                    onClicked: {
                        container.itemSelected( index  );
                        container.deactive();
                    }
                }
            }
        }

        Column {
            id : actionSheetColum
            width: parent.width
            height:( menuCancelbutton.height + 20 ) * actionSheetRepeater.count
            anchors {
                      bottom : menuCancelbutton.top
                      bottomMargin:10
                      horizontalCenter: parent.horizontalCenter
            }
            Repeater {
                id : actionSheetRepeater
                delegate: dialogDelete
            }
        }

        Button {
            id: menuCancelbutton
            text: "Cancel"
            textFontSize: 21
            textFontFamily: "Catriel"
            textFontBold: true
            textColor: "#F9F9F9"
            anchors { bottom : parent.bottom
                      bottomMargin:20
                      horizontalCenter: parent.horizontalCenter
            }
            normalIcon: application.getImageSource("button_up_normal_2.png")
            pressIcon: application.getImageSource("button_up_press.png")
            onClicked: {
                container.deactive();
            }
        }

        states: [
            State {
                name: "show"
                PropertyChanges { target: actionSheetItem; y: parent.height - actionSheetItem.height  }
            }

        ]

        transitions: [
            Transition {
                    NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
            },
            Transition {
                    NumberAnimation { properties: "opacity"; easing.type: Easing.InQuart; duration: 500 }
            }
        ]

    }

}


