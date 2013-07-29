import QtQuick 1.0
import TwitterEngine 1.0
import QtMobility.gallery 1.1
import "../components"
import "../apis"
import "../components/keyboard" as InputMethod
import "../javascript/localdata.js" as LocalDB

Item {
    id : tweetView
    width: parent.width
    height: parent.height

    //every view should have this property
    property int viewId: application.kNewTwitterView
    property int deleteBehaviour: viewmanager.noDelete

    property string title: "New Tweet"
    property string userName: application.screen_name
    property string reply_id: "" //reply tweet id; must has @someone in content
    property string draftModifiedTime: "" //edit draft must set this parameter

    property int countNum: 140
    property alias content: inputeditor.editorText
    property alias hasPic: section.hasPic
    property alias enableLoc: section.enableLoc
    property alias picLocalUrl: section.picLocalUrl
    property alias tweetAddress: section.localationString
    property alias _loading: section.loading
    property alias _locSucceed: section.locSucceed
    property int tweetType: _newTweet

    property string _filter: ""
    property variant locationDate

    property int _newTweet: 0
    property int _replyTweet: 1
    property int _editDraft: 2

    //every view should define below two functions
    function handleActivation()
    {
        console.log("newtwitter view handleActivation");
        sendBtn.enabled = checkSendable();
        inputeditor.editorCurseVisible = true;
        if (tweetType != _editDraft && !_locSucceed)
        {
            var now = new Date;
            now.setMinutes(now.getMinutes() - 15);
            console.log("Now: ", now.toTimeString());
            console.log("locationDate: ", locationDate.toTimeString());
            if(now > locationDate)
            {
                console.log("newtwitter view handleActivation reloc");
                _loading = true;
                newBlogapi.startLocation();
            }
            else
            {
                console.log("newtwitter view handleActivation not need reloc");
                _loading = false;
                _locSucceed = true;
            }
        }
        else
        {
            _loading = false;
        }
        if (!galleryModel.dataReady)
        {
            galleryModel.reload();
        }
    }

    function handleDeactivation()
    {
        console.log("newtwitter view is deactivated");
        if(languageIsEn)
        {
            inputeditor.deactiveNokiaInputMethod();
        }
    }

    function setContent(str)
    {
        inputeditor.handleKeyEvent(str);
    }

    function openAitelist()
    {
        locHide.start();
        inputeditor.cursorPos = inputeditor.editorText.length;
        inputeditor.handleKeyEvent("@");
    }

    function openTopiclist()
    {
        locHide.start();
        inputeditor.cursorPos = inputeditor.editorText.length;
        inputeditor.handleKeyEvent("#");
    }

    function hideList()
    {
        listRect.setListType(listRect._noList);
    }

    function resetView()
    {
        title = "New Tweet";
        reply_id = "";
        draftModifiedTime = "";
        inputeditor.state = "";
        section.positionViewAtIndex(0, ListView.Beginning);;
        section.currentIndex = 0;
        galleryModel.dataReady = false;

        countNum = 140;
        inputeditor.reset();
        hasPic = false;
        enableLoc = true;
        picLocalUrl = "";
        tweetType = _newTweet;

        _filter = "";
        _loading = true;
        _locSucceed = false;
    }

    function openCamera() {
        camerabg.visible = true;
        camerabg.opacity = 1.0;
        newBlogapi.openCamera();
    }

    function handleTextChanged()
    {
        var lastAt = inputeditor.editorText.lastIndexOf("@");
        var lastHash = inputeditor.editorText.lastIndexOf("#");
        var lastSpace = inputeditor.editorText.lastIndexOf(" ");
        var length = inputeditor.editorText.length;
        var type = listRect._noList;

        if(lastAt > lastHash && lastAt > lastSpace)
        {
            _filter = "";
            if(lastAt < length)
            {
                _filter = inputeditor.editorText.substring(lastAt+1);
            }
            listRect.loadAtMe(_filter);
            type = listRect._atMe;
        }
        else if(lastHash > lastAt && lastHash > lastSpace)
        {
            _filter = "";
            if(lastHash < length)
            {
                _filter = inputeditor.editorText.substring(lastHash+1);
            }
            listRect.loadTopic(_filter);
            type = listRect._topic;
        }
        else
        {
            type = listRect._noList;
        }
        listRect.setListType(type);
    }

    function restByte()
    {
        var str = "";
        var num = countNum - inputeditor.editorText.length;
        if(hasPic)
        {
            num -= 22;
        }
        str += num;
        return str;
    }

    function checkSendable()
    {
        var num = countNum - inputeditor.editorText.length;
        var able = false;
        if(hasPic)
        {
            num -= 22;
        }
        if(num >= 0 && num < 140)
        {
            able = true;
        }
        return able;
    }

    MouseArea {
        // to avoid click event dispatch to covered views
        anchors.fill: parent
    }

    Image {
        id: topZone
        anchors.top: parent.top
        z: 3
        source: application.getImageSource("bg_topzone.png");

        Button {
            anchors {verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 15}
            normalIcon: application.getImageSource("write_button_close_normal.png")
            pressIcon: application.getImageSource("write_button_close_press.png")
            onClicked: {
                if(tweetView.tweetType == tweetView._editDraft)
                {
                    var now = new Date;
                    var dataStr = "";
                    dataStr += now.valueOf();
                    LocalDB.updateDraftInfo(tweetView.title, tweetView.content, tweetView.picLocalUrl,
                                            tweetView.enableLoc, newBlogapi.placeString,
                                            dataStr, tweetView.draftModifiedTime);
                    var view = viewmanager.getView(application.kDraftListView, false);
                    view.refreshList();
                    viewmanager.back(viewmanager.slidePopdown);
                    tweetView.resetView();
                }
                else if(tweetView.hasPic || inputeditor.editorText.length > 0)
                {
                    closeDialog.active();
                }
                else
                {
                    viewmanager.back(viewmanager.slidePopdown);
                    tweetView.resetView();
                }
            }
        }

        Button {
            id: sendBtn
            anchors {verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 15}
            normalIcon: application.getImageSource("write_button_send_normal.png")
            pressIcon: application.getImageSource("write_button_send_press.png")
            disableIcon: application.getImageSource("write_button_send_unable.png")
            enabled: tweetView.checkSendable()
            onClicked: {
                if(tweetType == _replyTweet && !hasPic)
                {
                    newBlogapi.postReplyblog(inputeditor.editorText, reply_id, tweetView.enableLoc);
                }
                else if(hasPic)
                {
                    newBlogapi.postNewblogWithMedia(inputeditor.editorText, picLocalUrl, tweetView.enableLoc);
                }
                else
                {
                    newBlogapi.postNewblog(inputeditor.editorText, tweetView.enableLoc);
                }
                loadingdlg.visible = true;
            }
        }

        Column {
             spacing: 2
             anchors.centerIn: parent
             Text {
                 anchors.horizontalCenter: parent.horizontalCenter
                 horizontalAlignment: Text.AlignHCenter
                 width: 180
                 text: tweetView.title
                 color: "#F0FFFF"
                 font { pixelSize: 21; bold: true }
                 elide: Text.ElideRight
             }

             Text {
                 anchors.horizontalCenter: parent.horizontalCenter
                 horizontalAlignment: Text.AlignHCenter
                 verticalAlignment: Text.AlignTop
                 width: 180
                 text: "@" + tweetView.userName
                 color: "#F0FFFF"
                 font { pixelSize: 18; bold: false }
                 elide: Text.ElideRight
             }
         }
    }

    Image {
        id: category
        source: application.getImageSource("bg_categorybar_write.png");
        anchors.bottom: section.top

        Image {
            id : aite
            source: aitearea.pressed? application.getImageSource("write_button_aite_press.png") : application.getImageSource("write_button_aite_normal.png")
            x: 10
            MouseArea {
                id: aitearea
                anchors.fill: parent
                enabled: true
                onClicked: {
                    console.log("aite area mouse is pressed");
                    openAitelist();
                }
            }
        }

        Image {
            id : hash
            source: hasharea.pressed? application.getImageSource("write_button_hash_press.png") : application.getImageSource("write_button_hash_normal.png")
            x: aite.x + aite.width
            MouseArea {
                id: hasharea
                anchors.fill: parent
                enabled: true
                onClicked: {
                    openTopiclist();
                    console.log("hash area mouse is pressed");
                }
            }
        }

        Image {
            id : camera
            source: tweetView.hasPic ? application.getImageSource("write_button_cam_hold.png") : application.getImageSource("write_button_cam_normal.png")
            x: hash.x + hash.width
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(inputeditor.state == "")
                    {
                        inputeditor.hideKeyboard();
                    }
                    else if(section.currentIndex === 1)
                    {
                        section.decrementCurrentIndex();
                    }
                    else
                    {
                        inputeditor.state = "";
                    }
                }
            }
        }

        Image {
            id : location
            source: tweetView.enableLoc? application.getImageSource("write_button_location_hold.png") : application.getImageSource("write_button_location_normal.png")
            x: camera.x + camera.width
            visible: !tweetView._loading
            opacity: tweetView._loading ? 0.0 : 1.0
            MouseArea {
                anchors.fill: parent
                enabled: tweetView._loading == false
                onClicked: {
                    if(inputeditor.state == "")
                    {
                        locShow.start();
                    }
                    else if(section.currentIndex === 0)
                    {
                        section.incrementCurrentIndex();
                    }
                    else
                    {
                        locHide.start();
                    }
                }
            }
        }

        Image {
            id : loadIcon
            source: application.getImageSource("loading_s_01.png")
            anchors.centerIn: location
            visible: tweetView._loading
            opacity: tweetView._loading ? 1.0 : 0.0
            NumberAnimation on rotation {
                running: tweetView._loading; from: 0; to: 360; loops: Animation.Infinite; duration: 4800
            }
        }

        Text {
            id : count
            anchors { right: parent.right;
                      rightMargin: 20
                      verticalCenter: parent.verticalCenter }
            width: 38
            font.pixelSize: 21
            font.family: "Catriel"
            color: "#A6A6A6"
            text : tweetView.restByte()
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width; height: 270
        color: "#F9F9F9"
    }

    TweetHListView {
        id: section
        anchors.bottom: parent.bottom
        width: parent.width;
        height: 270
        scrollVisible: (listRect.listType == listRect._noList) && (inputeditor.state !== "" || !inputeditor.enableKeyboard)

        onCameraBtnClicked: {
            openCamera();
        }

        onGalleryBtnClicked: {
            if(galleryModel.dataReady) {
                var view = viewmanager.getView(application.kGalleyView, false);
                view.albumModel = albumModel;
                view.photosModel = photoModel;
                view.hasPhotos = (albumModel.count > 0);
                viewmanager.activateView(view, viewmanager.slidePopup);
            }
        }

        onLocationBtnClicked: {
            if(tweetView.enableLoc)
            {
                locHide.start();
                newBlogapi.cancelLocation();
                tweetView._loading = false;
                if(localationString === "Location refreshing")
                {
                    localationString = "Unknown Place";
                }
            }
            else if(!tweetView._locSucceed)
            {
                newBlogapi.startLocation();
                section.setDefaultLocationImg();
                tweetView._loading = true;
                localationString = "Location refreshing";
            }
            tweetView.enableLoc = !tweetView.enableLoc;
        }

        onPicLoadingStatusChanged: {
            loadingdlg.visible = !isFinish;
        }

        onSendStatusChanged: {
            sendBtn.enabled = tweetView.checkSendable();
        }

    }

    PopupList {
        id: listRect
        y: category.y - 130
        height: 130 + category.height
        width: tweetView.width

        onStringAppended: {
            inputeditor.handleKeyEvent(content.substring(tweetView._filter.length));
        }
    }

    Rectangle {
        anchors { top: topZone.bottom; bottom: listRect.listType > 0 ? listRect.top : category.top }
        width: parent.width
        InputMethod.CustomEditor {
            id: inputeditor
            height: listRect.listType > 0 ? listRect.y - topZone.height : category.y - topZone.height
            maxInputTextLength: (tweetView.hasPic)? countNum - 22: countNum
            textWrapMode: TextEdit.Wrap
            editorVAlignment: (paintedHeight > listRect.y - topZone.height && listRect.listType > 0) ? TextEdit.AlignBottom : TextEdit.AlignTop

            onTextValueChanged : {
                sendBtn.enabled = tweetView.checkSendable();
                handleTextChanged();
            }

            onKeyboardActived: {
                if(section.currentIndex == 1)
                {
                    locHide.start();
                }
                state = "";
            }
        }
    }

    Image {
        id: camerabg
        x: -140
        z: 3
        visible: false
        opacity: 0.0
        source: application.getImageSource("camera_bg.png");
        MouseArea {
           anchors.fill: parent
           enabled: camerabg.visible
        }
    }

    LoadingDlg {
        id: loadingdlg
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        visible: false
    }

    Note {
        id: notedlg
        visible: false
        source: application.getImageSource("wrongmark.png");
    }

    ListModel {
        id :closeAction
        ListElement {
            displayText:"Don't Save"
            destructive: true
        }
        ListElement {
            displayText:"Save Draft"
            destructive: false
        }
    }

    ActionSheet {
        id : closeDialog
        model:closeAction
        onItemSelected: {
            if(index === 1)
            {
                var now = new Date;
                var dataStr = "";
                dataStr += now.valueOf();
                LocalDB.appendDraftInfo(tweetView.title, tweetView.content, tweetView.picLocalUrl,
                                        tweetView.enableLoc, newBlogapi.placeString, dataStr);
                if(viewmanager.viewExists(application.kDraftListView))
                {
                    var view = viewmanager.getView(application.kDraftListView, false);
                    view.refreshList();
                }
            }
            viewmanager.back(viewmanager.slidePopdown);
            tweetView.resetView();
        }
    }

    ListModel {
        id: albumModel
    }

    ListModel {
        id: photoModel
    }

    DocumentGalleryModel {
        id: galleryModel
        property bool dataReady: false
        rootType: DocumentGallery.Image
        properties: [ "url", "fileName", "filePath", "lastModified","mimeType" ]
        sortProperties: [ "lastModified" ]
        onStatusChanged: {
            if(status == DocumentGalleryModel.Finished)
            {
                photoModel.clear();
                var header = "image://thumbnail/";
                for ( var index = galleryModel.count - 1; index >=0; index-- )
                {
                    if(galleryModel.get(index).mimeType !== "image/gif" && galleryModel.get(index).mimeType !== "image/tiff")
                    {
                        photoModel.append( { "thumbnail" : header + galleryModel.get(index).filePath,
                                             "url" :  galleryModel.get(index).url } );
                    }
                }

                albumModel.clear();
                if(photoModel.count > 0)
                {
                    albumModel.append({ "icon_url" : photoModel.get(0).thumbnail,
                                        "line1Text" : "Saved Photos (" + photoModel.count + ")",
                                        "line2Text" : "" });
                }
                dataReady = true;
            }
        }
    }

    ApiNewBlog {
        id: newBlogapi
        onLocalDone: {
            tweetView.tweetAddress = newBlogapi.placeString;
            if(newBlogapi.validLatitude(newBlogapi.latitude) && newBlogapi.validLongitude(newBlogapi.longitude)
               && newBlogapi.placeString !== "Unknown Place")
            {
                tweetView._locSucceed = true;
                locationDate = new Date;
                section.setLocationImgByGeo(newBlogapi.latitude, newBlogapi.longitude);
            }
            else
            {
                section.setDefaultLocationImg();
            }
        }

        onCameraClosed: {
            newBlogapi.setPortrait();
            camerabg.visible = false;
            camerabg.opacity = 0.0;
            if(filePath !== "")
            {
                var patt = new RegExp("file:///", "i");
                var path = filePath;
                if(filePath.search(patt) === -1)
                {
                    path = "file:///" + filePath;
                    console.log(path);
                }
                tweetView.picLocalUrl = path;
                tweetView.hasPic = true;
            }
            else
            {
                tweetView.picLocalUrl = "";
                tweetView.hasPic = false;
            }
            sendBtn.enabled = tweetView.checkSendable();
        }

        onBlogPosted: {
            loadingdlg.visible = false;
            if(tweetType == tweetView._editDraft)
            {
                LocalDB.removeDraft(tweetView.draftModifiedTime);
                var view = viewmanager.getView(application.kDraftListView, false);
                view.refreshList();
            }
            viewmanager.back(viewmanager.slidePopdown);
            tweetView.resetView();
        }

        onErrorOccured: {
            loadingdlg.visible = false;
            notedlg.visible = true;
        }
    }

    SequentialAnimation {
        id: locShow
        ScriptAction { script: {
                section.positionViewAtIndex(1, ListView.Beginning);
                section.currentIndex = 1; } }
        ScriptAction { script: {
                inputeditor.hideKeyboard() } }
    }

    SequentialAnimation {
        id: locHide
        PropertyAction { target: inputeditor; property: "state"; value: "" }
        PropertyAnimation { target: listRect; property: "width"; from: tweetView.width; to: tweetView.width; duration: 500 }
        ScriptAction { script: {
                section.positionViewAtIndex(0, ListView.Beginning);
                section.currentIndex = 0; } }
    }

    Component.onCompleted: {
        locationDate = new Date(2000, 1, 1, 0, 0, 0, 0);
    }
}

