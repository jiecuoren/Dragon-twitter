import QtQuick 1.0
import "../components"
import "../components/keyboard"
import "../javascript/commonFunction.js" as CommonFunction

Item {
    id: conversionView
    width: parent.width
    height: parent.height

    property variant conversionModel
    property alias messageCount: conversionList.model
    property int conversionIndex: 0
    property string user_id: ""
    property string screen_name: ""
    property alias backButtonText: leftBtn.text

    property string _messageIdToDelete;
    property Item _apiDM: null

    //every view should have this property
    property int viewId: application.kConversionView
    property int deleteBehaviour: viewmanager.deleteOnBack

    //every view should define below two functions
    function handleActivation()
    {
        console.log("conversation view is activated");
    }

    function handleDeactivation()
    {
        console.log("conversation view is deactivated");
        _apiDM.messageSent.disconnect(onMessageSent)
        _apiDM.messageSentError.disconnect(onMessageSentError)
        _apiDM.messageDestroyed.disconnect(onMessageDestroyed)
    }

    function setApi(aApi)
    {
        _apiDM = aApi;
        _apiDM.messageSent.connect(onMessageSent)
        _apiDM.messageSentError.connect(onMessageSentError)
        _apiDM.messageDestroyed.connect(onMessageDestroyed)
    }

    function showProfile(index)
    {
        var view = viewmanager.getView(kUserProfileView, true);
        if (conversionModel.conversion.get(index).isReceived)
        {
            view.setProfileInfo(conversionModel.peer_user_profile, false);
            view.setNavBarText("Conversion", conversionModel.peer_user_profile.screen_name);
        }
        else
        {
            view.setProfileInfo(application.userInfo, false);
            view.setNavBarText(" More", " My Profile");
        }
        viewmanager.activateView(view, viewmanager.slideLeft);
    }

    function onMessageSent()
    {
        console.log("ConversionView::function onMessageSent()")
        loadingDialog.visible = false
        messageEditor.reset();
        messageEditor.hideKeyboard();
        inputArea.isKeyboardShown = false
    }

    function onMessageSentError()
    {
        console.log("ConversionView::function onMessageSentError()")
        loadingDialog.visible = false
    }

    function onMessageDestroyed()
    {
        console.log("ConversionView::function onMessageDestroyed()")
        loadingDialog.visible = false
    }

    function buildMailbody()
    {
        if (messageCount > 0)
        {
            var body = "";
            for (var i = 0; i < messageCount; ++i)
            {
                var name = conversionModel.conversion.get(i).isReceived ? conversionModel.peer_user_profile.name : application.userInfo.name;
                var screen_name = conversionModel.conversion.get(i).isReceived ? conversionModel.peer_user_profile.screen_name : application.screen_name;
                var dateTime = CommonFunction.formatDatetime(conversionModel.conversion.get(i).created_at);
                var messageText = conversionModel.conversion.get(i).messageText;
                var oneMessageContent = name + " (@" + screen_name + ")  " + dateTime + "\n" + messageText + "\n\n";

                body += oneMessageContent;
            }

            return body;
        }

        return "";
    }

    Image {
        id: navigationBar
        anchors{top: parent.top}
        source: application.getImageSource("bg_topzone.png");

        Button {
            id: leftBtn
            pressIcon: application.getImageSource("button_bg_01_press.png");
            normalIcon: application.getImageSource("button_bg_01_normal.png");
            x: 10
            text: "Messages"
            textFontSize: 18
            textColor: "white"
            anchors {verticalCenter: parent.verticalCenter}

            onClicked: {
                viewmanager.back(viewmanager.slideRight);
            }
        }

        Text {
            id: title
            width: parent.width - leftBtn.width - leftBtn.anchors.leftMargin
                      - rightBtn.width - rightBtn.anchors.rightMargin - 25
            anchors{top: leftBtn.top; left: leftBtn.right; leftMargin: 10}
            font {pixelSize: 30; family: "Catriel"; bold: true}
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "white"
            text: screen_name
            elide: Text.ElideRight
        }

        Button {
            id: rightBtn
            pressIcon: application.getImageSource("home_button_export_press.png");
            normalIcon: application.getImageSource("home_button_export_normal.png");
            anchors {verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 17}
            z: messageEditor.editorText.length > 0 ? 1 : 2
            visible: messageEditor.editorText.length === 0 && (messageCount > 0)
            onClicked: {
                conversionActionSheet.active();
            }
        }

        Button {
            id: sendButton
            anchors {verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 17}
            pressIcon: application.getImageSource("write_button_send_press.png")
            normalIcon: application.getImageSource("write_button_send_normal.png")
            disableIcon: application.getImageSource("write_button_send_unable.png")
            visible: messageEditor.editorText.length > 0
            z: messageEditor.editorText.length > 0 ? 2 : 1
            enabled: messageEditor.editorText.length > 0
            onClicked: {
                _apiDM.sendMessage(user_id, screen_name, messageEditor.editorText);
                loadingDialog.visible = true
            }
        }
    }// end of navigationBar

    Component {
        id: listDelegate

        Item {
            id: container
            width: parent.width
            height: Math.max(userIcon.height + 10, messageTime.height + chatBubble.height + 10)

            property int iconBorderMargin: 5
            property int iconBubbleMargin: 4

            Text {
                id: messageTime
                color: "white"
                anchors {horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 3}
                text: CommonFunction.formatDatetime(conversionModel.conversion.get(index).created_at)
            }

            BorderImage {
                id: chatBubble
                border {top: 11; bottom: 28;
                        left: conversionModel.conversion.get(index).isReceived ? 28 : 13;
                        right: conversionModel.conversion.get(index).isReceived ? 13 : 28;}
                verticalTileMode: BorderImage.Stretch
                horizontalTileMode: BorderImage.Stretch
                source: conversionModel.conversion.get(index).isReceived ? application.getImageSource("chat_bubble_white.png") :application.getImageSource("chat_bubble_blue.png")
                anchors {top: messageTime.bottom; topMargin: 3}
                height: Math.max(border.bottom + border.top, messageText.height + 8)
                width: messageText.paintedWidth + border.left + border.right

                Text {
                    id: messageText
                    color: "black"
                    width: container.width - userIcon.width - iconBorderMargin - 2*iconBubbleMargin - chatBubble.border.left - chatBubble.border.right
                    x: chatBubble.border.left
                    anchors {verticalCenter: chatBubble.verticalCenter}

                    wrapMode: Text.WordWrap
                    text: conversionModel.conversion.get(index).messageText
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        _messageIdToDelete = conversionModel.conversion.get(index).id_str
                        messageActionSheet.active();
                    }
                }
            }

            ProfileImg {
                id: userIcon
                anchors {bottom: parent.bottom; bottomMargin: 2}
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        showProfile(index);
                    }
                }
            }

            Component.onCompleted: {
                //setup the properties for messageText and userIcon
                if (conversionModel.conversion.get(index).isReceived)
                {
                    if (conversionModel.peer_user_profile.default_profile_image)
                    {
                        userIcon.profileSource = application.getImageSource("avatar_default.png")
                    }
                    else
                    {
                        userIcon.profileSource = conversionModel.peer_user_profile.profile_image_url
                    }

                    userIcon.anchors.left = container.left
                    userIcon.anchors.leftMargin = iconBorderMargin
                    chatBubble.anchors.left = userIcon.right
                    chatBubble.anchors.leftMargin = iconBubbleMargin
                }
                else
                {
                    if (application.userInfo.default_profile_image)
                    {
                        userIcon.profileSource = application.getImageSource("avatar_default.png")
                    }
                    else
                    {
                        userIcon.profileSource = application.userInfo.profile_image_url
                    }

                    userIcon.anchors.right = container.right
                    userIcon.anchors.rightMargin = iconBorderMargin

                    chatBubble.anchors.right = userIcon.left
                    chatBubble.anchors.rightMargin = iconBubbleMargin
                }
            }
        }
    }

    ListView {
        id: conversionList

        anchors {left: parent.left; right: parent.right; top: navigationBar.bottom;
                 bottom: inputArea.top}
        clip: true
        delegate: listDelegate

        onModelChanged: {
            if (contentHeight > height)
            {
                contentY = contentHeight - height
            }
            else
            {
                contentY = 0;
            }
        }

        onHeightChanged: {
            if (contentHeight > height)
            {
                contentY = contentHeight - height
            }
            else
            {
                contentY = 0;
            }
        }
    }

    //its anchor is exactly the same as list view
    MouseArea {
        id: maskMouseArea
        anchors {left: parent.left; right: parent.right; top: navigationBar.bottom;
                 bottom: inputArea.top}

        onPressed: {
            if (!inputArea.isKeyboardShown)
            {
                mouse.accepted = false
            }
        }

        onClicked: {
            messageEditor.hideKeyboard();
            inputArea.isKeyboardShown = false
        }
    }

    Item {
        id: inputArea
        width: parent.width
        height: limitText.height + inputBox.height + inputArea.anchors.topMargin
        y: parent.height - height - messageEditor.keyboardHeight * isKeyboardShown

        property bool isKeyboardShown: false

        Text {
            id: limitText
            anchors {top: inputArea.top; left: parent.left; right: parent.right; rightMargin: 5}
            color: "black"
            text: String(messageEditor.maxInputTextLength - messageEditor.editorText.length)
            horizontalAlignment: Text.AlignRight
        }

        BorderImage {
            id: inputBox
            anchors {left: parent.left; right: parent.right; top: limitText.bottom; topMargin: -6}
            border {left: 20; right: 20; top: 23; bottom: 8}
            height: border.top + border.bottom + messageEditor.height
            source: application.getImageSource("searchbar_bottom.png")
            horizontalTileMode: BorderImage.Stretch
            verticalTileMode: BorderImage.Stretch
        }

        Behavior on y { NumberAnimation {duration: 500} }
    }

    //at present, CustomEditor must be the direct child of view
    CustomEditor {
        id: messageEditor
        width: inputArea.width - inputBox.border.left - inputBox.border.right
        height: paintedHeight
        editorX: inputBox.border.left
        editorY: inputArea.y + limitText.height + inputBox.anchors.topMargin + inputBox.border.top
        state: "hideKeyboard"

        onKeyboardActived: {
            console.log("CustomEditor::onKeyboardActived");
            inputArea.isKeyboardShown = true
        }

        onTextValueChanged: {
            sendButton.enabled = editorText.length > 0
        }
    }

    LoadingDlg {
        id: loadingDialog
        visible: false
    }

    ListModel {
        id: messageOperation
        ListElement {displayText: "Delete Message"
                     destructive: true }
    }

    ActionSheet {
        id: messageActionSheet
        model: messageOperation

        onItemSelected: {
            handleMessageOperation(index);
        }
    }

    function handleMessageOperation(index)
    {
        var messageTab;
        switch (index)
        {
        case 0:
            messageTab = viewmanager.getView(application.kMainView, false).getTabAtIndex(2);
            messageTab.deleteMessage(_messageIdToDelete);
            conversionList.model = conversionList.model - 1;
            loadingDialog.visible = true
            break;

        default:
            break;
        }
    }

    ListModel {
        id: conversionOperation
        ListElement {displayText: "Mail Conversation"
                    destructive: false}
        ListElement {displayText: "Delete Conversation"
                    destructive: true}
    }

    ActionSheet {
        id: conversionActionSheet
        model: conversionOperation

        onItemSelected: {
            handleConversionOperation(index);
        }
    }

    function handleConversionOperation(index)
    {
        var messageTab;

        switch (index)
        {
        case 0:
            //mail conversation
            var mailBody = buildMailbody();
            var subject = "Conversation between @" + screen_name + " and @" + application.screen_name;
            Qt.openUrlExternally("mailto:?subject=" + subject + "&body=" + mailBody);
            console.log("the mail body is " + mailBody);
            break;

        case 1:
            //delete conversation
            viewmanager.back(viewmanager.slideRight);
            messageTab = viewmanager.getView(application.kMainView, false).getTabAtIndex(2);
            messageTab.deleteConversion(conversionModel.peer_user_id);
            break;

        default:
            break;
        }
    }
}
