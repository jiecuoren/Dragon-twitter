import QtQuick 1.0
import "../apis"
import "../javascript/commonFunction.js" as CommonFunction

Image {
    id : container

    property alias attachActionSheet: attachDialog
    property alias deleteActionSheet: deleteDialog
    property alias retweetActionSheet: retweetDialog
    property alias exportActionSheet: exportDialog
    property alias commonActionSheet: commonDialog
    property alias loadingDlg: loadingdlg
    property alias noteDlg: notedlg

    property variant _status
    property variant _userMentionsModel: ''
    property variant _urlsModel: ''
    property variant _mediaModel: ''

    //multi link need _linkIndex
    property int _linkIndex: 0
    //_linkModel is for all hyper link in main text blog
    property ListModel _linkModel: ListModel {}

    signal updateAddFavStatus( bool favorited )
    signal updateMyselfStatus( bool myself )
    signal updateHasAttach( bool attach )

    signal isAddSuccess( bool success )
    signal isDeleteSuccess( bool success )
    signal updateFavoriteStatusFromModel( string id,bool success )
    signal deleteTweetFromModel( string id )
    signal retweetStatusSuccessfully( bool success )

    function initData( obj )
    {
        console.log("initData start");

        _status = obj;

        _mediaModel = _status.media;
        _urlsModel = _status.urls;

        _userMentionsModel =  _status.user_mentions;

        container.updateAddFavStatus( !_status.favorited );
        container.updateMyselfStatus(  _status.user_id === application.user_id ? true : false );
        container.updateHasAttach( ( _urlsModel.count > 0 || _mediaModel.count > 0 ) ? true : false );

        console.log("initData end",_status.id);
    }

    function favBlog()
    {
        if ( !_status.favorited )
        {
            console.log("add fav " + _status.id);
            blogApi.addToFavorite( _status.id );
        }
        else
        {
            console.log("remove fav " + _status.id);
            blogApi.deleteFromFavorite( _status.id );
        }
    }

    function retweetStatus()
    {
        console.log("retweetStatus",_status.id);
        blogApi.retweet( _status.id );
    }

    function deleteStatus()
    {
        console.log("deleteStatus",_status.id);
        blogApi.deleteStatus( _status.id );
    }

    function getDispalyText( index )
    {
        var displayStr = ''
        if ( _linkModel.count > 0 )
        {
            displayStr = _linkModel.get(index).displayText;
        }
        return displayStr;
    }

    function getRepostText( index )
    {
        console.log("getRepostText start");
        var tempStr =''
        var repost_Text =''
        var isFind = false;

        var displayStr = getDispalyText( index );

        for ( var i = 0;i < _mediaModel.count; i++ )
        {
            if ( (typeof _mediaModel.get( i ).display_url) !== "undefined" )
            {
                if ( displayStr == _mediaModel.get( i ).display_url )
                {
                    tempStr = _mediaModel.get(i).url;
                    isFind = true;
                    break;
                }
            }
        }

        if ( !isFind )
        {
            for ( var j = 0;j < _urlsModel.count; j++ )
            {
                if ( (typeof _urlsModel.get( j ).display_url) !== "undefined" )
                {
                    if ( displayStr == _urlsModel.get( j ).display_url )
                    {
                        tempStr = _urlsModel.get(j).url;
                        isFind = true;
                        break;
                    }
                }
            }
        }
        repost_Text = tempStr + " /via " + "@" + _status.screen_name;
        console.log("getRepostText end",repost_Text);
        return repost_Text;
    }

    function setLinkModelDisplayElement()
    {
        if ( _linkModel.count > 0 )
        {
            _linkModel.clear();
        }
        for (var i = 0; i < _mediaModel.count; i++ )
        {
            if ( (typeof _mediaModel.get( i ).display_url) !== "undefined" )
            {
                _linkModel.append ( {"displayText":_mediaModel.get( i ).display_url,
                                      "destructive":false});
            }
            else
            {
                _linkModel.append ({ "displayText":"","destructive":false});
            }
        }
        for ( var j = 0; j < _urlsModel.count; j++ )
        {
            if ( (typeof _urlsModel.get( j ).display_url) !== "undefined" )
            {
                _linkModel.append ( {"displayText":_urlsModel.get( j ).display_url,
                                      "destructive":false});
            }
            else
            {
                _linkModel.append ({ "displayText":"","destructive":false});
            }
        }
        return _linkModel;
    }

    function handleAttachCommand( index )
    {
        var view;
        switch ( index )
        {
        case 0:
            var mail_link = getRepostText( _linkIndex );
            Qt.openUrlExternally("mailto:" + "?subject=" +" mail link"+ "&body=" + mail_link)
            break;
        case 1:
            var repost_link = getRepostText( _linkIndex );
            view = viewmanager.getView( application.kNewTwitterView, false );
            view.setContent( repost_link );
            viewmanager.activateView( view, viewmanager.slidePopup );
            break;
        default:
            break;
        }
    }

    function handleDeleteCommand( index )
    {
        console.log("handleDeleteCommand");
        var view;
        switch ( index )
        {
        case 0:
            console.log("handleDeleteCommand case 0");
            deleteStatus();
            break;
        default:
            break;
        }
    }

    function handleRetweetCommand( index )
    {
        var view;
        switch ( index )
        {
        case 0:
            loadingdlg.visible = true;
            retweetStatus();
            break;
        case 1:
            view = viewmanager.getView(application.kNewTwitterView, false);
            view.reply_id = _status.id;
            view.setContent( "@" + _status.screen_name + " " + CommonFunction.convert( _status.mini_blog_content ));
            viewmanager.activateView(view, viewmanager.slidePopup);
            break;
        default:
            break;
        }
    }

    function handleExportCommand( index )
    {
        var view;
        switch ( index )
        {
        case 0:
            Qt.openUrlExternally("mailto:" + "?subject=" +" mail tweet"+ "&body=" + CommonFunction.convert( _status.mini_blog_content ))
            break;

        default:
            break;
        }
    }

    ApiHomeTimeline {
        id : blogApi

        onAddFavoriteSuccessfully: {
            console.log("onAddFavoriteSuccessfully",id);
            _status.favorited = true;
            container.isAddSuccess( true );
            container.updateFavoriteStatusFromModel(id, true);
        }

        onDeleteFavoriteSuccessfully: {
            console.log("onDeleteFavoriteSuccessfully",id);
            _status.favorited = false;
            container.isDeleteSuccess(true);
            container.updateFavoriteStatusFromModel(id, false);
        }

        onAddFavoriteError: {
            console.log("onAddFavoriteError");
            container.isAddSuccess( false );
        }

        onDeleteFavoriteError: {
            console.log("onDeleteFavoriteError");
            container.isDeleteSuccess(false);
        }

        onRetweetedSuccessfully: {
            console.log("onRetweetedSuccessfully");
            container.retweetStatusSuccessfully( true );
        }

        onRetweetedError: {
            console.log("onRetweetedError");
            container.retweetStatusSuccessfully( false );
        }

        onDeleteStatusSuccessfully: {
            console.log("onDeleteStatusSuccessfully");
            container.deleteTweetFromModel( id );
        }

        onDeleteStatusError: {
            console.log("onDeleteStatusError");
        }

    }

    ListModel {
        id :attachModel

        ListElement {
            displayText:"Mail Link"
            destructive: false
        }
        ListElement {
            displayText:"Repost Link"
            destructive: false
        }
    }

    ListModel {
        id :deleteModel
        ListElement {
            displayText:"Delete Tweet"
            destructive: true
        }
    }

    ListModel {
        id :retweetModel
        ListElement {
            displayText:"Retweet"
            destructive: false
        }
        ListElement {
            displayText:"Quote Tweet"
            destructive: false
        }
    }

    ListModel {
        id :exportModel
        ListElement {
            displayText:"Mail Tweet"
            destructive: false
        }
    }

    ActionSheet {
        id: attachDialog
        parent: viewmanager
        model: attachModel
        onItemSelected: {
            console.log("attachActionSheet...",index);
            handleAttachCommand( index );
            console.log("attachActionSheet...");
        }
    }

    ActionSheet {
        id : deleteDialog
        parent: viewmanager
        model: deleteModel
        onItemSelected: {
            console.log("deleteActionSheet...",index);
            handleDeleteCommand( index );
        }
    }

    ActionSheet {
        id : retweetDialog
        parent: viewmanager
        model:retweetModel
        onItemSelected: {
            console.log("retweetActionSheet...",index);
            handleRetweetCommand( index );
        }
    }

    ActionSheet {
        id : exportDialog
        parent: viewmanager
        model:exportModel
        onItemSelected: {
            console.log("exportActionSheet...",index);
            handleExportCommand( index );

        }
    }

    ActionSheet {
        id : commonDialog
        parent: viewmanager
        model:_linkModel
        onItemSelected: {
            console.log("commonActionSheet...",index);
            _linkIndex =  index ;
            attachActionSheet.text = getDispalyText( _linkIndex );
            attachActionSheet.active();
            console.log("commonActionSheet...",_linkIndex);
        }
    }

    LoadingDlg {
        id: loadingdlg
        parent: viewmanager
        promptInfo: "Retweeting..."
        visible: false
    }

    Note {
        id: notedlg
        parent: viewmanager
        visible: false
    }
}
