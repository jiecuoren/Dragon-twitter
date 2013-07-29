import QtQuick 1.0
import "../components"
import "../javascript/localdata.js" as LocalDB

Item {
    id: container
    width: parent.width // parent is viewmanager(360 x 610)
    height: parent.height

    //every view should have this property
    property int viewId: application.kAboutView
    property int deleteBehaviour: viewmanager.deleteOnBack

    //every view should define below two functions
    function handleActivation()
    {
        console.log("About view handleActivation");
    }

    function handleDeactivation()
    {
        console.log("About view handleDeactivation");
    }

    function handleSignOutCommand( index )
    {
        switch ( index )
        {
        case 0:
            doSignOut();
            break;
        default:
            break;
        }
    }

    function doSignOut()
    {
        console.log("About view doSignOut");
        LocalDB.clearDraft();
        application.getStorage().clearDB();
        Qt.quit();
    }

    function buttonListClicked( index )
    {
        console.log("About view buttonListClicked, index is " + index);
        switch ( index )
        {
        case 0:
            Qt.openUrlExternally("http://dragonsightforce.com");
            break;
        case 1:
            sendMail();
            break;
        case 2:
            activeProfileView();
            break;

        default:
            break;
        }
    }

    function sendMail()
    {
        console.log("About view sendMail");
        var mailBody = "";
        var subject = "I need help for twitter client";
        Qt.openUrlExternally("mailto:dragonsighting@gmail.com?subject=" + subject + "&body=" + mailBody);
    }

    function activeProfileView()
    {
        console.log("About view activeProfileView");
        var view = viewmanager.getView(kUserProfileView, true);
        view.screen_name = "DragonSightTeam";
        view.setNavBarText(" About", "DragonSightTeam");
        viewmanager.activateView(view, viewmanager.slideLeft);
    }

    Image {
        id: navigationBar
        anchors{top: parent.top}
        width: container.width
        source: application.getImageSource("bg_topzone.png");

        Button {
            id: backBtn
            anchors { left: parent.left; leftMargin: 5; verticalCenter: parent.verticalCenter }
            normalIcon: application.getImageSource("button_bg_01_normal.png")
            pressIcon: application.getImageSource("button_bg_01_press.png")
            textColor: "white"
            text: " More"
            onClicked: {
                viewmanager.back(viewmanager.slideRight);
            }
        }

        Text {
            id: title
            anchors.centerIn: parent
            font {pixelSize: 30; family: "Catriel"; bold: true}
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "white"
            text: "About"
        }
    }

    Button {
        id: versionBtn
        pressIcon: application.getImageSource("button_single_normal.png");
        normalIcon: application.getImageSource("button_single_normal.png");
        text: "Version"
        textColor: "black"
        textX: 10
        textFontSize: 22
        anchors {top: navigationBar.bottom; topMargin: 20; horizontalCenter: parent.horizontalCenter}
        onClicked: {
            console.log("versionBtn clicked");
        }

        Text {
            id: versionText
            color: "gray"
            font.pixelSize: 15
            text: "1.10.0"
            anchors{right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter}
        }
    }

    Text {
        id: helpText
        x: 20
        anchors{top: versionBtn.bottom; topMargin: 10}
        color: "gray"
        font.pixelSize: 18
        text: "Looking for help?"
    }

    ButtonList {
        id: helpList
        model: buttonListmodel
        x: 20
        anchors{top: helpText.bottom; topMargin: 10}

        onItemSelected: {
            console.log("helpList clicked, index is " + index);
            buttonListClicked(index)
        }

        ListModel {
            id: buttonListmodel
            ListElement {full_name: "http://dragonsightforce.com"; mode: "public"}
            ListElement {full_name: "dragonsighting@gmail.com"; mode: "public"}
            ListElement {full_name: "@DragonSightTeam"; mode: "public"}
        }
    }

    Button {
        id: signOutBtn
        pressIcon: application.getImageSource("button_single_press.png");
        normalIcon: application.getImageSource("button_single_normal.png");
        text: "Sign out"
        textColor: "black"
        textFontSize: 22
        anchors {top: helpList.bottom; topMargin: -41; horizontalCenter: parent.horizontalCenter}
        onClicked: {
            console.log("versionBtn clicked");
            signOutDialog.active();
        }
    }

    ActionSheet {
        id: signOutDialog
        model: signOutModel
        text: "Application will quit \nafter signing out!"
        onItemSelected: {
            console.log("signOutDialog clicked, index is " + index);
            handleSignOutCommand( index );
        }

        ListModel {
            id :signOutModel
            ListElement {displayText:"Sign out"; destructive: true}
        }
    }

    Text {
        id: copyRight
        anchors{top: signOutBtn.bottom; topMargin: 10; horizontalCenter: parent.horizontalCenter}
        color: "gray"
        font.pixelSize: 18
        text: "Copyright © 2011 DragonSight"
    }

}
