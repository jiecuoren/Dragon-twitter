import QtQuick 1.0

ListView {
    id: container
    width: parent.width
    height: (count+1) * 61// if set to content height, will cause banding loop

    property int textWidth: 360 //set this property to different to active elide
    signal itemSelected(int index)

    spacing: 1
    interactive: false
    clip: true
    focus: true
    delegate: listDelegate

    Component {
        id: listDelegate

        SimpleButton {

                id: mainBtn

                function getPressIcon()
                {
                    if (0 === index)
                    {
                        if(mainBtn.ListView.view.count == 1)
                        {
                            return application.getImageSource("button_single_press.png")
                        }
                        return application.getImageSource("list_press_top.png")
                    }
                    else if ( mainBtn.ListView.view.count - 1 == index )
                    {
                        return application.getImageSource("list_press_bottom.png")
                    }
                    else
                    {
                        return application.getImageSource("list_press_mid.png")
                    }
                }

                function getNormalIcon()
                {
                    if (0 === index)
                    {
                        if(mainBtn.ListView.view.count == 1)
                        {
                            return application.getImageSource("button_single_normal.png")
                        }
                        return application.getImageSource("list_bg_top.png")
                    }
                    else if ( mainBtn.ListView.view.count -1 == index )
                    {
                        return application.getImageSource("list_bg_bottom.png")
                    }
                    else
                    {
                        return application.getImageSource("list_bg_mid.png")
                    }
                }
                pressIcon: getPressIcon()
                normalIcon: getNormalIcon()
                text: full_name
                textColor: "black"
                textX: 10
                textWidth: mainBtn.ListView.view.textWidth
                onClicked: {
                    console.log("clicked at index "+ index);
                    mainBtn.ListView.view.itemSelected(index);
                }

                Image {
                    anchors {right: parent.right; rightMargin: 5; verticalCenter: parent.verticalCenter}
                    source: (mode === "public") ? application.getImageSource("button_arrow_right.png")
                                                : application.getImageSource("button_lock.png")
                }

            } // end of simple btn
        }// end of component
    }
