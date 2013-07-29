import QtQuick 1.0

import "../components"
import "../models"
import "../apis"

Item {
    id: mainTextView

    //every view should have this property
    property int viewId: application.kMainTextView
    property int deleteBehaviour: viewmanager.deleteOnBack

    //need get from timeline model
    property int blogListModelIndex: 0
    property ListModel mainTextViewModel

    //every view should define below two functions
    function handleActivation()
    {
        console.log("main text view is activated start");
    }

    function handleDeactivation()
    {
        console.log("main text view is deactivated");
    }

    function initMainTextTopBarData( text )
    {
        topBar.buttonText = text;
        topBar.updateModelCount( mainTextList.model.count );
        topBar.updateIndex( mainTextView.blogListModelIndex );
        topBar.updateEnableProperty();
    }

    function initMainTextToolBarData ( obj )
    {
        toolbar.initData( obj );
    }

    width: parent.width
    height: parent.height

    Image {
        id: readBg
        anchors.fill: parent
        source: application.getImageSource("read_bg.png")
    }

    MainTextViewTopbar {
        id : topBar
        anchors.top: parent.top
        topBarText: ( mainTextList.currentIndex + 1 ) + " of " + mainTextList.count

        onUpButtonClicked: {
            mainTextList.decrementCurrentIndex();
            topBar.updateModelCount( mainTextList.count );
            topBar.updateIndex( mainTextList.currentIndex );
            topBar.updateEnableProperty();
            toolbar.initData( mainTextList.model.get( mainTextList.currentIndex ) );
        }

        onDownButtonClicked: {
            mainTextList.incrementCurrentIndex();
            topBar.updateModelCount( mainTextList.count );
            topBar.updateIndex( mainTextList.currentIndex );
            topBar.updateEnableProperty();
            toolbar.initData( mainTextList.model.get( mainTextList.currentIndex ) );
        }

    }

    MainTextList {
        id : mainTextList
        width: parent.width
        anchors.top: topBar.bottom

        model: mainTextViewModel
        currentIndex: mainTextView.blogListModelIndex

        onActiveProfileView: {
            console.log("onActiveProfileView",userid,fromMentions);
            var view;
            // active profile from main text mentions
            if ( fromMentions )
            {
                if ( userid !== application.user_id)
                {
                    var flag = false;
                    var k = 0;
                    for (var i = 0;i < mainTextList.model.get( mainTextList.currentIndex ).user_mentions.count; i++ )
                    {
                        if ( mainTextList.model.get( mainTextList.currentIndex ).user_mentions.get(i).id_str === userid )
                        {
                            k= i;
                            flag = true;
                            break;
                        }
                    }
                    if ( flag )
                    {
                        view = viewmanager.getView(kUserProfileView, true);
                        view.screen_name = mainTextList.model.get( mainTextList.currentIndex ).user_mentions.get(k).screen_name;
                        view.setNavBarText(" Tweet", view.screen_name);
                        viewmanager.activateView(view, viewmanager.slideLeft);
                    }
                }
                else
                {
                    view = viewmanager.getView(kUserProfileView, true);
                    view.setProfileInfo(application.userInfo, false);
                    view.setNavBarText(" Tweet", application.screen_name);
                    viewmanager.activateView(view, viewmanager.slideLeft);
                }
            }
            // active profile from main text topbar
            else if ( mainTextList.model.get( mainTextList.currentIndex ).retweeted_by === '' )
            {
                view = viewmanager.getView(kUserProfileView, true);
                //if from search, name always empty
                if( mainTextList.model.get( mainTextList.currentIndex ).name === "" )
                {
                    view.setProfileInfo(mainTextList.model.get( mainTextList.currentIndex ).user, true);
                }
                else
                {
                    view.setProfileInfo(mainTextList.model.get( mainTextList.currentIndex ).user, false);
                }
                view.setNavBarText(" Tweet", mainTextList.model.get( mainTextList.currentIndex ).screen_name);
                viewmanager.activateView(view, viewmanager.slideLeft);
            }
            else
            {
                view = viewmanager.getView(kUserProfileView, true);
                view.screen_name = mainTextList.model.get( mainTextList.currentIndex ).screen_name;
                view.setNavBarText(" Tweet", view.screen_name);
                viewmanager.activateView(view, viewmanager.slideLeft);
            }

        }

        onActiveRetweetUserProfileView: {
            console.log("onActiveRetweetUserProfileView",screenname);
            var view = viewmanager.getView(kUserProfileView, true);
            if (screenname == application.screen_name)
            {
                view.setProfileInfo(application.userInfo, false);
                view.setNavBarText(" Tweet", application.screen_name);
            }
            else
            {
                view.screen_name = screenname;
                view.setNavBarText(" Tweet", view.screen_name);
            }
            viewmanager.activateView(view, viewmanager.slideLeft);
        }

        onActiveSearchView: {
            console.log("onActiveSearchView",hashtags);
            var view = viewmanager.getView( application.kSearchResultView, true);
            view.buttonText = "Tweet";
            view.title = hashtags;
            view.queryText = hashtags;
            viewmanager.activateView( view, viewmanager.slideLeft );
        }

        onActiveUrlWebView: {
            console.log("onActiveUrlWebView",url);
            Qt.openUrlExternally( url );
        }

        onActiveOriginalImageView: {
            console.log("onActiveOriginalImageView",image);
            var view = viewmanager.getView( kShowOriginalImageView, true );
            view.source = image;
            if ( mainTextList.model.get( mainTextList.currentIndex ).media.count > 0 )
            {
                if (typeof mainTextList.model.get( mainTextList.currentIndex ).media.get(0).url !== "undefined")
                {
                    view.addressUrl = mainTextList.model.get( mainTextList.currentIndex ).media.get(0).url;
                }
                else
                {
                    view.addressUrl = image;
                }
            }
            viewmanager.activateView(view, viewmanager.slideLeft);
        }

        onActivePreviousView: {
            viewmanager.back( viewmanager.slideRight );
        }

    }

    //toolbar
    MainTextToolbar {
        id: toolbar

        width: parent.width
        anchors.bottom: parent.bottom

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
                mainTextList.model.updateFavoriteStatus(id,true);
            }
            else
            {
                mainTextList.model.updateFavoriteStatus(id,false);
            }
        }

        onDeleteTweetFromModel: {
            mainTextList.model.deleteTweet(id);
            viewmanager.back( viewmanager.slideRight );
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
            console.log("onForwardClicked");
            var view = viewmanager.getView( application.kNewTwitterView, false);
            view.reply_id = _status.id;
            view.title = "Reply to " + _status.screen_name;
            view.setContent("@" + _status.screen_name + " ");
            viewmanager.activateView(view, viewmanager.slidePopup);
        }

        onDeleteMySelfStatus: {
            console.log("onDeleteMySelfStatus");
            deleteActionSheet.active();
        }

        onRetweetClicked: {
            console.log("onRetweetClicked");
            retweetActionSheet.active();
        }

        onFavClicked: {
            console.log("onFavClicked start");
            favBlog();
            console.log("onFavClicked end ");
        }

        onAttachClicked: {
            console.log("onAttachClicked");
            setLinkModelDisplayElement();
            commonActionSheet.active();
        }

        onExportClicked: {
            console.log("onExportClicked");
            exportActionSheet.active();
        }

    }

}
