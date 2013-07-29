import QtQuick 1.0
import QtMultimediaKit 1.1
import "../models"

TwitterList {
    id: container

    property Item getTweetsApi: null
    property Item checkNewTweetApi: null
    property int oldTweetsCount: 0
    property string _showText: 'Timeline'
    property bool checkNew: true
    property bool supportPopupMenu: true

    model: ModelBlogList {}
    delegate: BlogListComponent {}
    twitterListView.highlight: highlightComponent

    supportRefresh: true

    function setGetTweetsApi(theApi)
    {
        getTweetsApi = theApi;
        getTweetsApi.targetModel = model;

        getTweetsApi.dataReceived.connect(onDataReceived);
        getTweetsApi.errorOccured.connect(onErrorOccured);
        getTweetsApi.lastPageReached.connect(onLastPageReached);
    }

    function setCheckNewTweetApi(theApi)
    {
        checkNewTweetApi = theApi;
        checkNewTweetApi.targetModel = model;

        checkNewTweetApi.newTweetFound.connect(onNewTweetFound);
    }

    function getNewTweets()
    {
        oldTweetsCount = model.count;
        getTweetsApi.getNewTweets();
        isRefreshing = true
        checkNewTweetTimer.stop();
    }

    function getOldTweets()
    {
        oldTweetsCount = model.count;
        getTweetsApi.getOldTweets();
        isRefreshing = true;
    }

    function setMainTextTopBarLeftText( text )
    {
        _showText = text;
    }

    function onDataReceived(isNewTweets)
    {
        isRefreshing = false;
        checkModelData();

        var newTweetsCount = model.count;
        var diff = newTweetsCount - oldTweetsCount;
        if (diff > 0)
        {
            if (diff === 1)
            {
                infoText.text = "Fetched 1 tweet";
            }
            else
            {
                infoText.text = "Fetched " + (newTweetsCount - oldTweetsCount) + " tweets";
            }

            if(application.voiceNote)
            {
                console.log("Yes, voice played!");
                voiceNote.play();
            }
        }
        else
        {
            infoText.text = "No new tweets";
        }

        infobar.show();

        if (isNewTweets)
        {
            //restart the timer after we've got new tweets
            checkNewTweetTimer.start();

            //use checkNewTweetApi to judge if this component is in a tabbed ui
            if (checkNewTweetApi !== null)
            {
                //new tweets are received, the tab's hasNewData should be false!
                parent.parent.hasNewData = false
            }
        }

        updateLastUpdateTime();
    }

    function onErrorOccured()
    {
        isRefreshing = false;
        checkModelData();
        //restart the timer after we've got new tweets
        if (!checkNewTweetTimer.running)
        {
            checkNewTweetTimer.start();
        }
    }

    function onLastPageReached()
    {
        reachEnd = true
    }

    function onNewTweetFound()
    {
        parent.parent.hasNewData = true
    }

    function interActiveListView( interactive )
    {
        twitterListView.interactive = interactive;
    }

    function showPopUpMenu( index )
    {
        if ( !supportPopupMenu || isRefreshing )
        {
            return;
        }

        if ( toolBarMenuAnimation.running || backAnimation.running )
        {
             return;
        }

        interActiveListView( false );
        twitterListView.currentIndex = index;

        toolBarMenuAnimation.highlightItem = twitterListView.highlightItem;
        toolBarMenuAnimation.currentItem = twitterListView.currentItem;
        toolBarMenuAnimation.highlightItem.initData(twitterListView.model.get(twitterListView.currentIndex));
        toolBarMenuAnimation.start();

    }

    function hidePopUpMenu()
    {
        if ( !supportPopupMenu || isRefreshing )
        {
            return;
        }

        if ( twitterListView.currentIndex >= 0 )
        {
            if ( backAnimation.running || toolBarMenuAnimation.running )
            {
                return;
            }
            backAnimation.highlightItem = twitterListView.highlightItem;
            backAnimation.currentItem = twitterListView.currentItem;
            if ( backAnimation.highlightItem.opacity >= 1.0 )
            {
                backAnimation.start();
            }
        }
    }

    function setHighLightToNull()
    {
         twitterListView.currentIndex = -1;
    }

    onRefreshTriggered: {
        getNewTweets();
    }

    onLoadMoreTriggered: {
        getOldTweets();
    }

    onItemSelected: {
        console.log("item " + index + " is selected");
        hidePopUpMenu();
        var view = viewmanager.getView( application.kMainTextView, true);
        view.blogListModelIndex = index;
        view.mainTextViewModel = model;
        view.initMainTextTopBarData(_showText);
        view.initMainTextToolBarData( model.get(index) );
        viewmanager.activateView(view, viewmanager.slideLeft);
    }

    onPopUpMenuTriggered: {
        showPopUpMenu( index );
    }

    onMouseYPosChanged: {
        if ( index != twitterListView.currentIndex )
        {
            interActiveListView( true );
        }
    }

    onListMoveStarted: {
        hidePopUpMenu();
    }

    Audio {
        id: voiceNote
        source: "../default/msgcome.wav"
    }

    Component {
        id: highlightComponent
        PopupMenu {
            id : popupMenu
            height: (twitterListView.currentIndex >= 0)? twitterListView.currentItem.height: 0
            y: (twitterListView.currentIndex >= 0)? twitterListView.currentItem.y : 0

            onUpdateAddFavStatus: {
                updateAddFavStatus( favorited );
            }

            onUpdateHasAttach: {
                updateHasAttach( attach );
            }

            onUpdateMyselfStatus: {
                updateMyselfStatus( myself );
            }

            onIsAddSuccess: {
                isAddSuccess( success );
            }

            onIsDeleteSuccess: {
                isDeleteSuccess( success );
            }

            onUpdateFavoriteStatusFromModel: {
                if ( success )
                {
                    twitterListView.model.updateFavoriteStatus(id,true);
                }
                else
                {
                    twitterListView.model.updateFavoriteStatus(id,false);
                }
            }

            onRetweetStatusSuccessfully: {

                if ( success )
                {
                    loadingDlg.visible = false;
                    noteDlg.visible =  true;
                    noteDlg.source = application.getImageSource("rightmark.png");
                    noteDlg.promptInfo = "Retweeted";
                }
                else
                {
                    loadingDlg.visible = false;
                    noteDlg.visible =  true;
                    noteDlg.source = application.getImageSource("wrongmark.png");
                    noteDlg.promptInfo = "Retweet Error";
                }
            }

            onReplyClicked: {
                hidePopUpMenu();
                var view = viewmanager.getView( application.kNewTwitterView, false);
                view.reply_id = _status.id;
                view.title = "Reply to " + _status.screen_name;
                view.setContent("@" + _status.screen_name + " ");
                viewmanager.activateView(view, viewmanager.slidePopup);
            }

            onRetweetClicked :{
                hidePopUpMenu();
                retweetActionSheet.active();
            }

            onFavClicked: {
                hidePopUpMenu();
                favBlog();
            }

            onProfileClicked:{
                // active profile from popupMenu
                hidePopUpMenu();
                var view;
                view = viewmanager.getView(kUserProfileView, true);
                if ( _status.retweeted_by === '' )
                {
                    //if from search, name always empty
                    if( _status.name === "" )
                    {
                        view.setProfileInfo(_status.user, true);
                    }
                    else
                    {
                        view.setProfileInfo(_status.user, false);
                    }
                    view.setNavBarText(" Tweet", _status.screen_name);
                }
                else
                {
                    view.screen_name = _status.screen_name;
                    view.setNavBarText(" Tweet", view.screen_name);
                }
                viewmanager.activateView(view, viewmanager.slideLeft);
            }

            onAttachClicked: {
                hidePopUpMenu();
                setLinkModelDisplayElement();
                commonActionSheet.active();
            }

            onExportClicked: {
                console.log("onExportClicked start");
                hidePopUpMenu();
                exportActionSheet.active();
                console.log("onExportClicked end");
            }
       }
    }

    NumberAnimation {
        id: moveback
        target: toolBarMenuAnimation.previousItem; property: "x";
        from:twitterListView.width; to: 0; duration: 400;
        easing.type: Easing.OutBounce ;easing.amplitude:0.3
    }

    SequentialAnimation {
        id: toolBarMenuAnimation
        running: false

        property Item highlightItem;
        property Item previousItem;
        property Item currentItem;

        ParallelAnimation {
            PropertyAnimation { target: toolBarMenuAnimation.highlightItem; property: "opacity";
                                from: 0.0;to: 1.0; duration: 400;
                                easing.type: Easing.Linear }

            NumberAnimation { target: toolBarMenuAnimation.highlightItem; property: "width";
                              from: 0;to: twitterListView.width; duration: 400;
                              easing.type: Easing.Linear }

            NumberAnimation { target: toolBarMenuAnimation.currentItem; property: "x";
                              from: 0;to: twitterListView.width;duration: 400;
                              easing.type: Easing.Linear }

            ScriptAction {
                script: {
                    if(toolBarMenuAnimation.previousItem !== null)
                    {
                        moveback.start();
                    }
                }
            }
        }

        ScriptAction {
            script: {
                toolBarMenuAnimation.previousItem = toolBarMenuAnimation.currentItem;
            }
        }

    }

    SequentialAnimation {
        id : backAnimation
        running: false
        property Item currentItem;
        property Item highlightItem;

        PropertyAction { target: backAnimation.highlightItem; property: "opacity"; value: 0.0 }

        NumberAnimation { target: backAnimation.currentItem; property: "x";
                          from: twitterListView.width; to: 0; duration: 400;
                          easing.type: Easing.OutBounce ; easing.amplitude:0.3 }

        ScriptAction {
            script: {
                toolBarMenuAnimation.previousItem = null;
            }
        }
    }

    Image {
        id: infobar
        source: application.getImageSource("infobar.png")
        anchors {bottom: parent.bottom}
        visible: false
        opacity: 1.0

        function show()
        {
            visible = true
            opacity = 1.0
            controlTimer.start();
        }

        Text {
            id: infoText
            anchors.centerIn: parent
            color: "white"
        }

        Timer {
            id: controlTimer
            interval: 3000
            repeat: false
            running: false

            onTriggered: {
                hideAnimation.start();
            }
        }

        SequentialAnimation {
            id: hideAnimation
            PropertyAnimation {target: infobar; property: "opacity"; from: 1.0; to: 0.4;
                duration: 500}

            PropertyAction {target: infobar; property: "visible"; value: false}
        }
    }

    //a timer is used to check new tweet and update the created_at text
    Timer {
        id: checkNewTweetTimer
        running: true
        repeat: true
        interval: 60*1000 //60 seconds
        onTriggered: {
            if (checkNewTweetApi !== null && checkNew)
            {
                if (!container.parent.parent.hasNewData)
                {
                    checkNewTweetApi.checkNewTweet();
                }
            }

            model.updateCreatedAtShort();
        }
    }

}
