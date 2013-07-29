import QtQuick 1.0
import "../models"

TwitterList {
    id: container

    property bool supportFollow: false
    property int _followIndex: 0

    property Item getUserApi: null

    model: ModelUserList {}
    delegate: UserListComponent {}
    supportRefresh: false

    signal follow( int index, bool follow )

    function setGetUserApi(theApi)
    {
        getUserApi = theApi;
        getUserApi.targetModel = model;

        getUserApi.dataReceived.connect(onDataReceived);
        getUserApi.errorOccured.connect(onErrorOccured);
        getUserApi.lastPageReached.connect(onLastPageReached);

        if ( supportFollow )
        {
            getUserApi.followSuccessfully.connect(onFollowSuccessfully);
            getUserApi.unfollowSuccessfully.connect(onUnfollowSuccessfully);
            getUserApi.followFailed.connect(onFollowFailed);
            getUserApi.unfollowFailed.connect(onUnfollowFailed);
        }
    }

    function intiUserIds(aScreenName)
    {
        getUserApi.intiUserIds(aScreenName);
        isRefreshing = true
    }

    function getMoreUser()
    {
        isRefreshing = true;
        getUserApi.requestUserInfo();
    }

    function searchUser( query ,page )
    {
        getUserApi.searchUser( query , page );
        isRefreshing = true;
    }

    function followUser( user_id )
    {
        getUserApi.followCreate( user_id );
        loadingdlg.promptInfo = "following"
        loadingdlg.visible = true;
    }

    function unfollowUser( user_id )
    {
        getUserApi.followDestory( user_id );
        loadingdlg.promptInfo = "unfollowing"
        loadingdlg.visible = true;
    }

    function onFollowSuccessfully()
    {
        console.log("Suggested USERS View  onFollowSuccessfully");
        getUserApi.targetModel.setProperty(_followIndex, "following", true );
        loadingdlg.visible = false;
        notedlg.visible =  true;
        notedlg.source = application.getImageSource("rightmark.png");
        notedlg.promptInfo = "follow successfully";
    }

    function onFollowFailed()
    {
        console.log("Suggested USERS View  onFollowFailed");
        loadingdlg.visible = false;
        notedlg.visible =  true;
        notedlg.source = application.getImageSource("wrongmark.png");
        notedlg.promptInfo = "follow failed";
    }

    function onUnfollowSuccessfully()
    {
        console.log("Suggested USERS View  onUnfollowSuccessfully");
        getUserApi.targetModel.setProperty(_followIndex, "following", false );
        loadingdlg.visible = false;
        notedlg.visible =  true;
        notedlg.source = application.getImageSource("rightmark.png");
        notedlg.promptInfo = "unfollow successfully";
    }

    function onUnfollowFailed()
    {
        console.log("Suggested USERS View  onUnfollowFailed");
        loadingdlg.visible = false;
        notedlg.visible =  true;
        notedlg.source = application.getImageSource("wrongmark.png");
        notedlg.promptInfo = "unfollow failed";
    }

    function onDataReceived(isNewTweets)
    {
        isRefreshing = false;
        checkModelData();
        updateLastUpdateTime();
    }

    function onErrorOccured()
    {
        console.log("error occured in user list");
        checkModelData();
        isRefreshing = false;
    }

    function onLastPageReached()
    {
        reachEnd = true
        isRefreshing = false;
    }

    onLoadMoreTriggered: {
        getMoreUser();
    }

    onFollow: {
        console.log("User list on follow",index,follow);
        _followIndex =  index;
        if ( follow )
        {
            followUser(getUserApi.targetModel.get(index).id_str);
        }
        else
        {
            unfollowUser(getUserApi.targetModel.get(index).id_str);
        }
    }

    LoadingDlg {
        id: loadingdlg
        anchors{
            top: parent.top
            bottom: parent.bottom
        }
        visible: false
    }

    Note {
        id: notedlg
        visible: false
    }
}
