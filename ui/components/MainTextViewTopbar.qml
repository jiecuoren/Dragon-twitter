import QtQuick 1.0

Image {
    id : container

    property alias topBarText: modelindex.text
    property alias buttonText: topButton.text

    property int index: 0
    property int count: 20

    signal upButtonClicked()
    signal downButtonClicked()

    function updateModelCount( modelCount )
    {
        container.count = modelCount;
    }

    function updateIndex( currentIndex )
    {
        container.index = currentIndex;
    }

    function updateEnableProperty( )
    {
        if ( container.count <= 1 )
        {
            up.enabled = false;
            down.enabled = false;
        }
        else if ( container.index <= 0 )
        {
            up.enabled = false;
            down.enabled = true;
        }
        else if ( container.index >= container.count - 1 )
        {
            up.enabled = true;
            down.enabled = false;
        }
        else
        {
            up.enabled = true;
            down.enabled = true;
        }
    }

    source: application.getImageSource("bg_topzone.png")

    Button {
        id: topButton
        normalIcon: application.getImageSource("button_bg_01_normal.png")
        pressIcon: application.getImageSource("button_bg_01_press.png")
        textFontSize: 18
        textFontFamily: "Catriel"
        textFontBold: true
        textColor: "#F0FFFF"
        text : "Timeline"
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 13
        }

        onClicked: {
            console.log("left btn in home page clicked!");
            viewmanager.back( viewmanager.slideRight );
        }
    }

    Item {
        id: textItem
        anchors {
            verticalCenter: parent.verticalCenter
            left: topButton.right
            right: up.left
        }

        Text {
            id: modelindex
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            font { pixelSize: 24; family: "Catriel"; bold:true }
            color:"#F0FFFF"
        }
    }

    Button {
        id: up
        normalIcon: application.getImageSource("botton_uparrow_normal.png")
        pressIcon: application.getImageSource("botton_uparrow_press.png")
        disableIcon: application.getImageSource("botton_uparrow_unable.png")
        anchors {
            verticalCenter: parent.verticalCenter
            right: down.left
        }
        onClicked: {
            container.upButtonClicked();
        }

    }

    Button {
        id: down
        normalIcon: application.getImageSource("botton_downarrow_normal.png")
        pressIcon: application.getImageSource("botton_downarrow_press.png")
        disableIcon: application.getImageSource("botton_downarrow_unable.png")
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 13
        }
        onClicked: {
            container.downButtonClicked();
        }

    }

}

