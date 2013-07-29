import QtQuick 1.0

ToolBarMenuBase {
    id: container

    signal replyClicked()
    signal retweetClicked()
    signal favClicked()
    signal attachClicked()
    signal exportClicked()
    signal deleteMySelfStatus()

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
            button2.normalIcon = application.getImageSource("button_delete_normal.png");
            button2.pressIcon = application.getImageSource("button_delete_press.png");
        }
        else
        {
            button2.normalIcon = application.getImageSource("read_button_retweet_normal.png");
            button2.pressIcon = application.getImageSource("read_button_retweet_press.png");
        }
    }

    function updateHasAttach( hasAttach )
    {
        if ( hasAttach )
        {
            button4.normalIcon = application.getImageSource("read_button_attach_normal.png");
            button4.enabled = true;
        }
        else
        {
            button4.enabled = false;
        }
    }

    width: parent.width
    source: application.getImageSource("bg_categorybar_read.png")

    Row {
        anchors.fill: parent
        spacing: 10

        Button {
            id: leftbutton
            normalIcon: application.getImageSource("read_button_forward_normal.png")
            pressIcon: application.getImageSource("read_button_forward_press.png")
            anchors { verticalCenter: parent.verticalCenter }
            onClicked: {
                container.replyClicked();
            }
        }

        Button {
            id: button2
            normalIcon:  application.getImageSource("button_delete_normal.png")
            pressIcon:  application.getImageSource("button_delete_press.png")
            anchors { verticalCenter: parent.verticalCenter}
            onClicked: {
                if (  _status.user_id === application.user_id )
                {
                    container.deleteMySelfStatus();
                }
                else
                {
                    container.retweetClicked();
                }
            }
        }

        Button {
            id: button3
            normalIcon:  application.getImageSource("read_button_fav_normal.png")
            pressIcon: application.getImageSource("button_fav_press.png")
            anchors { verticalCenter: parent.verticalCenter }
            onClicked: {
                container.favClicked( );
            }
        }

        Button {
            id: button4
            normalIcon: application.getImageSource("read_button_attach_normal.png")
            pressIcon: application.getImageSource("read_button_attach_press.png")
            disableIcon: application.getImageSource("read_button_attach_unable.png");
            anchors { verticalCenter: parent.verticalCenter }
            onClicked: {
                container.attachClicked();
            }
        }

        Button {
            id: rightbutton
            normalIcon: application.getImageSource("read_button_export_normal.png")
            pressIcon: application.getImageSource("read_button_export_press.png")
            anchors { verticalCenter: parent.verticalCenter}
            onClicked: {
                container.exportClicked();
            }
        }
    }

}

