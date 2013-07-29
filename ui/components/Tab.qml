import QtQuick 1.0

Loader {
    id: container
    // name of the tab
    property string name

    // icons to be displayed in the tab
    property url inactiveIcon
    property url activeIcon

    property bool hasNewData: false

    property bool clickedAble: true

    function startAnimation()
    {
        fadeoutAnimation.running = true
    }

    anchors.fill: parent

    PropertyAnimation {
        id: fadeoutAnimation
        running: false
        target: container;
        property: "opacity";
        from: 0.3;
        to: 1.0;
        duration: 500
    }
}
