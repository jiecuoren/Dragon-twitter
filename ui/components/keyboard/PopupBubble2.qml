import QtQuick 1.0

Image {
    id: root;
    z: 1000;
    property bool showPopup : false;

    function getSuffix()
    {
        if(position === "left")
            return "_left.png"
        if(position === "right")
            return "_right.png"
        else
            return ".png"
    }

    function getHOffset()
    {
        if(position === "left")
            return -5;
        if(position === "right")
            return 5;
        else
            return 0
    }

    opacity: 0;
    state: showPopup ? "visible" : "";

    property string position: "center";
    property string text;

    source: application.getImagePath() + "bubble" + getSuffix()

    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            horizontalCenterOffset: getHOffset()
            verticalCenterOffset: -8
        }
        text: root.text;
        font.pointSize: 14;
        font.bold: true;
        color: "white";
    }

    states:  State {
            name: "visible"
            PropertyChanges {
                target: root
                opacity: 1.0;
            }
    }

    transitions: Transition {
                from: "visible"; to: ""
                NumberAnimation {  properties: "opacity"; duration: 500; }
    }

}
