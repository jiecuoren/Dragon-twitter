import QtQuick 1.0

import "../apis"
import "../models"
import "../components"
import "../javascript/commonFunction.js" as CommonFunction

Item {
    id: container
    anchors.fill: parent

    function handleActivition()
    {
        //the first time log in case
        apiDM.getAllReceivedMessages();
    }

    function positionViewAtBeginning()
    {
        conversionList.positionViewAtIndex(0, ListView.Beginning);
    }

    Component.onCompleted: {
        //firstly, we should get all messages (received and sent). When this is finished, we start
        //the check new message timer
        if (application.user_id !== "")
        {
            //signed up case
            apiDM.getAllReceivedMessages();
        }
    }

    function gotoConversionViewByIndex(index, fromTabMessages)
    {
        console.log("tabMessage::function gotoConversionViewByIndex(index)");
        var view = viewmanager.getView(application.kConversionView, true);
        view.conversionModel = conversionListModel.get(index);
        view.messageCount = conversionListModel.get(index).conversion.count;
        view.conversionIndex = index;
        view.user_id = conversionListModel.get(index).peer_user_profile.id_str;
        view.screen_name = conversionListModel.get(index).peer_user_profile.screen_name;
        if (!fromTabMessages)
        {
            view.backButtonText = view.screen_name;
        }

        view.setApi(apiDM);

        conversionListModel.setProperty(index, "unreadFlag", false);
        viewmanager.activateView(view, viewmanager.slideLeft);

        if (0 === conversionListModel.getUnreadCount())
        {
            container.parent.hasNewData = false;
        }
    }

    function gotoConversionViewByPeerUserId(peer_user_id, screen_name)
    {
        var index = -1;
        for (var i = 0; i < conversionListModel.count; ++i)
        {
            if (conversionListModel.get(i).peer_user_id == peer_user_id)
            {
                index = i;
                break;
            }
        }

        console.log("function gotoConversionViewByPeerUserId, peer_user_id is " + peer_user_id + ", screen_name is " + screen_name);
        console.log(" index found is " + index);
        if (index >= 0 && index < conversionListModel.count)
        {
            gotoConversionViewByIndex(index, false);
        }
        else
        {
            //which case can run to here? answer: write a direct message to a follower,
            //but they don't have history messages
            var view = viewmanager.getView(application.kConversionView, true);
            //can't set conversionModel for the moment, will update it after a new message is sent
            view.messageCount = 0;
            view.conversionIndex = 0;
            view.user_id = peer_user_id;
            view.screen_name = screen_name;
            view.backButtonText = screen_name;
            view.setApi(apiDM);
            viewmanager.activateView(view, viewmanager.slideLeft);
        }
    }

    function deleteConversion(peer_user_id)
    {
        console.log("tabMessage::function deleteConversion(peer_user_id)");
        apiDM.deleteConversion(peer_user_id);
    }

    function deleteMessage(messageId)
    {
        console.log("tabMessage::function deleteMessage(messageId)");
        conversionListModel.deleteMessage(messageId);
        apiDM.destroyMessage(messageId);
    }

    function getApiDirectMessages()
    {
        return apiDM;
    }

    ApiDirectMessages {
        id: apiDM

        onDataReceived:
        {
            //after model is ready, set it to list view. otherwise there's problem
            conversionList.model = conversionListModel;
        }

        onRetrieveAllFinished: {
            checkNewMessageTimer.start();
        }

        onNewMessageReceived: {
            console.log("tabMessages.qml, onNewMessageReceived");
            //should update conversion view if it exists
            if (viewmanager.viewExists(application.kConversionView))
            {
                console.log("the conversion view exists, should update it");
                var view = viewmanager.getView(application.kConversionView, false);
                view.conversionModel = conversionListModel.get(view.conversionIndex);
                view.messageCount = conversionListModel.get(view.conversionIndex).conversion.count;
            }

            container.parent.hasNewData = true
        }

        onMessageDestroyed: {
        }

        onMessageSent: {
            //should update conversion view if it exists
            if (viewmanager.viewExists(application.kConversionView))
            {
                console.log("the conversion view exists, should update it");
                var view = viewmanager.getView(application.kConversionView, false);
                view.conversionModel = conversionListModel.get(view.conversionIndex);
                view.messageCount = conversionListModel.get(view.conversionIndex).conversion.count;
            }
        }
    }

    ModelMessageList {
        id: conversionListModel

        onCountChanged: {
            if (0 === count)
            {
                conversionList.model = null;
            }
        }
    }

    Component {
        id: listViewDelegate
        Rectangle {
            width: parent.width
            height: Math.max(userIcon.height + 6, userName.height + messageContent.height + 12)

            function getIndicatorIcon()
            {
                if (!conversion.get(conversion.count-1).isReceived)
                {
                    return application.getImageSource("sign_forward.png")
                }
                else
                {
                    if (unreadFlag)
                    {
                        return application.getImageSource("sign_unread.png")
                    }
                    else
                    {
                        return "";
                    }
                }
            }

            MouseArea {
                id: itemMouseArea
                anchors.fill: parent
                onClicked: {
                    gotoConversionViewByIndex(index, true);
                 }
            }

            // lines of top
            Image {
                id: topLine
                width: parent.width
                anchors {top: parent.top}
                source: application.getImageSource("line_list_top.png")
            }

            // lines of bottom
            Image {
                id: bottomLine
                width: parent.width
                anchors {bottom: parent.bottom}
                source: application.getImageSource("line_list_bottom.png")
            }

            Image {
                id: highLightImage
                anchors.fill: parent
                source: application.getImageSource("list_press.png")
                visible: itemMouseArea.pressed
            }

            Image {
                id: indicator
                width: 18
                height: 16
                anchors {verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 4}
                source: getIndicatorIcon()
            }

            ProfileImg {
                id: userIcon
                anchors {left: indicator.right; top: topLine.bottom; leftMargin: 4; topMargin: 2}
                profileSource: (peer_user_profile.default_profile_image) ?
                               application.getImageSource("avatar_default.png") :
                               peer_user_profile.profile_image_url
            }

            Text {
                id: userName
                text: peer_user_profile.screen_name
                color: "black"
                font {pixelSize: 18; bold: true}
                anchors {left:  userIcon.right; leftMargin: 5; top: userIcon.top}
            }

            Text {
                id: createdTime
                text: CommonFunction.formatDatetime(conversion.get(conversion.count - 1).created_at)
                color: "gray"
                font {pixelSize: 15; bold: true}
                anchors {right:  parent.right;
                         rightMargin: 2;
                         top: userName.top}
            }

            Text {
                id: messageContent
                anchors {top: userName.bottom; topMargin: 5; left: userName.left;
                         right: rightArrow.left; rightMargin: -10}
                wrapMode: Text.WordWrap
                text: conversion.get(conversion.count - 1).messageText
                color:"#1E1E1E"
                font.pixelSize: 17
            }

            Image {
                id: rightArrow
                source: application.getImageSource("button_arrow_right.png")
                anchors {verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: -6}
            }
        }
    }

    ListView {
        id: conversionList
        anchors {fill: parent}
        clip: true
        delegate: listViewDelegate
    }

    Text {
        width: parent.width - 10
        anchors.centerIn: parent
        text: "Messages will appear here. You can only send them to people who follow you, and only people you follow can send them to you."
        horizontalAlignment: Text.AlignHCenter
        color: "white"
        wrapMode: Text.WordWrap
        visible: conversionListModel.count == 0
    }

    //a timer is used to check new message and update the created_at text
    Timer {
        id: checkNewMessageTimer
        running: false
        repeat: true
        interval: 120*1000 //2 minutes
        onTriggered: {
            apiDM.checkNewMessage();
        }
    }
}
