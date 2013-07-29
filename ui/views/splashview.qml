import QtQuick 1.0
import "../components"

Image {
    id: splashview
    anchors.fill: parent
    source: application.getImageSource("greeting_bg.png")

    //every view should have this property
    property int viewId: application.kSplashView
    property int deleteBehaviour : viewmanager.deleteOnHide

    // if need to input username & password
    property bool needUserInfo: false

    //every view should define below two functions
    function handleActivation()
    {
        console.log("splash view is activated");
    }

    function handleDeactivation()
    {
        console.log("splash view is deactivated");
    }

    Timer {
        id: timer
        interval: 2 * 1000  //2 seconds
        repeat:  false
        running: true

        onTriggered: {
            if (application.user_id !== ""){
                viewmanager.activateViewById(application.kMainView, viewmanager.fade);
            }
            else
            {
                viewmanager.activateViewById(application.kSignupView, viewmanager.fade);
            }
        }
    }
}
