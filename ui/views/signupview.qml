import QtQuick 1.0
import "../components"

Image {
    anchors.fill: parent
    source: application.getImageSource("greeting_bg.png")

    property int viewId: application.kSignupView
    property int deleteBehaviour : viewmanager.noDelete  //changed to 'noDelete' to handle user refuses auth case

    function handleActivation()
    {
        console.log("signup view is activated");
    }

    function handleDeactivation()
    {
        console.log("signup view is deactivated");
        loadingImg.visible = false
    }

    function errorHandler(data)
    {
        console.log(data);
        loadingImg.visible = false
        noteDlg.visible = true
    }

    Button {
        x: 10
        y: 10
        normalIcon: application.getImageSource("home_button_exit_normal.png")
        pressIcon: application.getImageSource("home_button_exit_press.png")
        onClicked: {
            Qt.quit();
        }
    }

    Button {
        anchors {horizontalCenter: parent.horizontalCenter}
        y: 465
        normalIcon: application.getImageSource("button_signin_normal.png")
        pressIcon:  application.getImageSource("button_signin_press.png")
        onClicked: {
            loadingImg.visible = true
            application.getAuthorize().requestToken(errorHandler);
        }
    }

    Image {
        id: loadingImg
        source: application.getImageSource("loading_bottom_" + String(counter%4+1) + ".png")
        anchors {horizontalCenter: parent.horizontalCenter; bottom: parent.bottom}
        visible: false
        property int counter: 0

        Timer {
            id: timer
            interval: 100
            running: loadingImg.visible
            repeat: true

            onTriggered: {
                ++loadingImg.counter;
            }
        }
    }

    Note {
        id: noteDlg
        source: application.getImageSource("wrongmark.png")
        promptInfo: "Network error!"
        visible: false
    }
}
