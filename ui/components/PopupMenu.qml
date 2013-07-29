import QtQuick 1.0

ToolBarMenuBase {
    id: container

    signal replyClicked()
    signal retweetClicked()
    signal favClicked()
    signal profileClicked()
    signal attachClicked()
    signal exportClicked()

    function isAddSuccess( isAddSuccess )
    {
        if ( isAddSuccess )
        {
            button3.normalIcon = application.getImageSource("read_button_fav_press.png");
            button3.pressIcon = application.getImageSource("button_fav_press.png");
        }
    }

    function isDeleteSuccess ( isDeleteSuccess )
    {
        if ( isDeleteSuccess )
        {
            button3.normalIcon = application.getImageSource("read_button_fav_normal.png");
            button3.pressIcon = application.getImageSource("button_fav_press.png");
        }
    }

    function updateAddFavStatus( isAdd )
    {
        if ( isAdd )
        {
            button3.normalIcon = application.getImageSource("read_button_fav_normal.png");
            button3.pressIcon = application.getImageSource("button_fav_press.png");
        }
        else
        {
            button3.normalIcon = application.getImageSource("read_button_fav_press.png");
            button3.pressIcon = application.getImageSource("button_fav_press.png");
        }
    }

    function updateMyselfStatus ( isMyself )
    {
        if ( isMyself )
        {
            button2.opacity = 0.3;
        }
        else
        {
            button2.opacity = 1.0;
        }
    }

    function updateHasAttach( hasAttach )
    {
        if ( hasAttach )
        {

            button5.opacity = 1.0;
        }
        else
        {
            button5.opacity = 0.3;
        }
    }

    source: application.getImageSource("bg_categorybar_read.png")
    z: 2

    Button {
        id: leftbutton
        visible: container.width > width
        opacity: container.opacity
        normalIcon: application.getImageSource("read_button_forward_normal.png")
        pressIcon: application.getImageSource("read_button_forward_press.png")
        anchors {
            verticalCenter: parent.verticalCenter
            left:parent.left
            leftMargin: 3
        }
        onClicked: {
            container.replyClicked();
        }
    }

    Button {
        id: button2
        visible: container.width > 2*width
        opacity: container.opacity
        normalIcon: application.getImageSource("read_button_retweet_normal.png")
        pressIcon: application.getImageSource("read_button_retweet_press.png")
        anchors {
            verticalCenter: parent.verticalCenter
            left:leftbutton.right
            leftMargin: 3
        }
        onClicked: {
            if ( opacity >= 1.0 )
            {
                 container.retweetClicked();
            }
        }
    }

    Button {
        id: button3
        visible: container.width > 3*width
        opacity: container.opacity
        normalIcon:  application.getImageSource("read_button_fav_normal.png")
        pressIcon: application.getImageSource("button_fav_press.png")
        anchors {
            verticalCenter: parent.verticalCenter
            left:button2.right
            leftMargin: 3
        }
        onClicked: {
            container.favClicked();
        }
    }

    Button {
        id: button4
        visible: container.width > 4*width
        opacity: container.opacity
        normalIcon:  application.getImageSource("button_people_normal.png")
        pressIcon: application.getImageSource("button_people_press.png")
        anchors {
            verticalCenter: parent.verticalCenter
            left:button3.right
            leftMargin: 3
        }
        onClicked: {
            container.profileClicked();
        }
    }

    Button {
        id: button5
        visible: container.width > 5*width
        opacity: container.opacity
        normalIcon: application.getImageSource("read_button_attach_normal.png")
        pressIcon: application.getImageSource("read_button_attach_press.png")
        anchors {
            verticalCenter: parent.verticalCenter
            left:button4.right
            leftMargin: 3
        }
        onClicked: {
            if ( opacity >= 1.0 )
            {
                container.attachClicked();
            }
        }
    }

    Button {
        id: rightbutton
        visible: container.width >= 6*width
        opacity: rightbutton.visible > 0 ? 1.0 : 0.0
        normalIcon: application.getImageSource("read_button_export_normal.png")
        pressIcon: application.getImageSource("read_button_export_press.png")
        anchors {
            verticalCenter: parent.verticalCenter
            left:button5.right
            leftMargin: 3
        }
        onClicked: {
            container.exportClicked();
        }
    }
}



