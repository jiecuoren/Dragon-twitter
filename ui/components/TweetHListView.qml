import QtQuick 1.0

// for new tweet view media and location page only
ListView {
    id: container
    height: parent.height
    width: parent.width

    property bool hasPic: false
    property bool enableLoc: true
    property bool loading: true
    property bool locSucceed: false
    property alias picLocalUrl: pictures.source
    property alias localationString: locString.text
    property bool scrollVisible: true

    function setLocationImgByGeo(lat, lon)
    {
        console.log("setLocationImgByGeo");
        var locationUrl = "http://maps.googleapis.com/maps/api/staticmap?center=%1, %2&zoom=15&size=%3x%4&sensor=false";
        locationImg.source = locationUrl.arg(lat).arg(lon).arg(locationImg.width).arg(locationImg.height);
        if(locationImg.status === Image.Ready)
        {
            loading = false;
        }
    }

    function setDefaultLocationImg()
    {
        locationImg.source = application.getImageSource("map_default.png");
        loading = false;
    }

    signal cameraBtnClicked();
    signal galleryBtnClicked();
    signal locationBtnClicked();
    signal picLoadingStatusChanged(bool isFinish);
    signal sendStatusChanged();

    orientation: ListView.Horizontal
    clip: false
    snapMode: ListView.SnapOneItem
    model: itemModel
    highlightRangeMode: ListView.StrictlyEnforceRange

    Image {
        id: trigleLine
        source: application.getImageSource("line_addlocationimg.png")
        opacity: scrollVisible ? 1.0 : 0.0
        x: container.visibleArea.xPosition * container.width / 3 - 170
        y: -10

        Behavior on opacity {
            NumberAnimation { duration: 400 }
        }
    }

    VisualItemModel {
        id: itemModel

        Item {
            id: picPage
            width: container.width;
            height: container.height

            SimpleButton {
                y: 15
                anchors.horizontalCenter: parent.horizontalCenter
                textFontSize: 21
                textColor: "#40637D"
                pressIcon: application.getImageSource("button_up_press.png")
                normalIcon: application.getImageSource("button_up_normal_1.png")
                text: "Take Photo..."
                visible: (!container.hasPic) ? true : false
                opacity: (!container.hasPic) ? 1.0 : 0.0
                onClicked: {
                    container.cameraBtnClicked();
                }
            }

            SimpleButton {
                y: 82
                anchors.horizontalCenter: parent.horizontalCenter
                textFontSize: 21
                textColor: "#40637D"
                pressIcon: application.getImageSource("button_up_press.png")
                normalIcon: application.getImageSource("button_up_normal_1.png")
                text: "Choose From Library..."
                visible: (!container.hasPic) ? true : false
                opacity: (!container.hasPic) ? 1.0 : 0.0
                onClicked: {
                    container.galleryBtnClicked();
                }
            }

            Image {
                id: pictures
                anchors { fill: parent; margins: 20 }
                fillMode: Image.PreserveAspectFit
                sourceSize.width: parent.width - 20
                sourceSize.height: parent.height - 20
                opacity: container.hasPic ? 1.0 : 0.0
                onStatusChanged: {
                    var picFinished = true;
                    if(Image.Loading == pictures.status)
                    {
                        picFinished = false;
                    }
                    container.picLoadingStatusChanged(picFinished);
                }

                Image {
                    x: (pictures.width - pictures.paintedWidth)/2 - 17
                    y: (pictures.height - pictures.paintedHeight)/2- 17
                    source: application.getImageSource("button_closepic.png")
                    visible: container.hasPic && pictures.status == Image.Ready
                    opacity: (container.hasPic) ? 1.0 : 0.0
                    MouseArea {
                        anchors.fill: parent
                        enabled: container.hasPic
                        onClicked: {
                            pictures.source = ''
                            container.hasPic = false;
                            container.sendStatusChanged();
                        }
                    }
                }
            }
        }

        Item {
            id: locPage
            width: container.width;
            height: container.height

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 10; width: 324;
                height : 160
                radius: 6
                border.color: (container.loading || !container.locSucceed || !container.enableLoc) ? "transparent":"gray"
                border.width: 2
                smooth : true
                clip: true
                Image {
                    id: locationImg
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    visible: !container.loading
                    opacity: container.loading? 0.0 : 1.0
                    source: application.getImageSource("map_default.png")
                    asynchronous: true
                    clip: true
                    onStatusChanged: {
                        if((status === Image.Ready || status === Image.Error) && container.locSucceed)
                        {
                            container.loading = false;
                        }
                    }
                }
                Image {
                    anchors.centerIn: parent
                    source: application.getImageSource("map_grid.png")
                    visible: !container.enableLoc
                    opacity: container.enableLoc ? 0.0 : 1.0
                }
                Image {
                    anchors.centerIn: parent
                    source: application.getImageSource("write_button_location_hold.png")
                    visible: container.enableLoc && container.locSucceed && !container.loading && locationImg.status != Image.Error
                    opacity: visible ? 1.0 : 0.0
                }
            }

            Text {
                id: locString
                width: parent.width
                height: 30
                x: 0
                y: 170
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "Location refreshing"
                color: "#3a3a3a"
                font { pixelSize: 15; bold: false }
            }

            SimpleButton {
                y: 198
                anchors.horizontalCenter: parent.horizontalCenter
                textFontSize: 21
                textColor: "#40637D"
                pressIcon: application.getImageSource("button_up_press.png")
                normalIcon: application.getImageSource("button_up_normal_1.png")
                text: "Turn " + (container.enableLoc? "Off" : "On") + " Location"
                onClicked: {
                    container.locationBtnClicked();
                }
            }
        }
    }
}
