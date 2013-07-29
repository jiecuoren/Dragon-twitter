import QtQuick 1.0
import TwitterEngine 1.0

import "javascript/authorize.js" as Authorize
import "javascript/oauth.js" as OAuth
import "javascript/storage.js" as Storage
import "javascript/componentsFactory.js" as ComponentsFactory
import "components"

Item
{
    id: application

    property int kSplashView: 0
    property int kMainView: 1
    property int kAuthWebView: 2
    property int kSignupView: 3
    property int kEditProfileView: 4
    property int kMainTextView: 5
    property int kShowOriginalImageView: 6
    property int kNewTwitterView: 7
    property int kUserProfileView: 8
    property int kSearchResultView: 9
    property int kSearchTweetsView: 10
    property int kSuggestedCategoryView: 11
    property int kUserListView: 12
    property int kGalleyView: 13
    property int kSuggestedUsersView: 14
    property int kConversionView: 15
    property int kRetweetsView: 16
    property int kListsView: 17
    property int kListsTweetsView: 18
    property int kDraftListView: 19
    property int kProfileLocation: 20
    property int kAboutView: 21
    //increase kMaxViewId when you add a new view id
    property int kMaxViewId: 22

    property string themeName: "default"

    property string user_id: ""
    property string screen_name: ""

    //this variable if for save user profile
    property variant userInfo

    //flag to control voiceNote
    property bool voiceNote: true

    //public functions
    function getImageSource(imageName)
    {
        return "image://theme/" + themeName + "/" + imageName;
    }

    //public functions
    function getImagePath()
    {
        return "image://theme/" + themeName + "/";
    }

    function getAuthorize()
    {
        return Authorize;
    }

    function getOAuth()
    {
        return OAuth;
    }

    function getStorage()
    {
        return Storage;
    }

    //except for kSplashView, all views' parent is viewmanager!
    function createView(viewId)
    {
        console.log("main.qml, createView(), viewId = " + viewId);
        var component;
        var view;
        switch (viewId)
        {
        case kSplashView:
            component = ComponentsFactory.getComponent(viewId, "views/splashview.qml");
            view = component.createObject(application);
            return view;

        case kMainView:
            component = ComponentsFactory.getComponent(viewId, "views/mainview.qml");
            view = component.createObject(viewmanager);
            return view;

        case kAuthWebView:
            component = ComponentsFactory.getComponent(viewId, "views/authwebview.qml");
            view = component.createObject(viewmanager);
            return view;
	    
        case kSignupView:
            component = ComponentsFactory.getComponent(viewId, "views/signupview.qml");
            view = component.createObject(viewmanager);
            return view;

        case kEditProfileView:
            component = ComponentsFactory.getComponent(viewId, "views/editProfileView.qml");
            view = component.createObject(viewmanager);
            return view;

        case kMainTextView:
            component = ComponentsFactory.getComponent(viewId,"views/MainTextView.qml");
            view = component.createObject(viewmanager);
            return view;

        case kShowOriginalImageView:
            component = ComponentsFactory.getComponent(viewId,"views/ShowOriginalImageView.qml");
            view = component.createObject(application);
            return view;
	    
        case kNewTwitterView:
            component = ComponentsFactory.getComponent(viewId, "views/newtwitter.qml");
            view = component.createObject(viewmanager);
            return view;
	    
	case kUserProfileView:
	    component = ComponentsFactory.getComponent(viewId, "views/UserProfileView.qml");
	    view = component.createObject(viewmanager);
	    return view;
	    
        case kSearchResultView:
            component = ComponentsFactory.getComponent(viewId,"views/SearchResultView.qml");
            view = component.createObject(viewmanager);
            return view;

        case kSearchTweetsView:
            component = ComponentsFactory.getComponent(viewId,"views/SearchTweetsView.qml");
            view = component.createObject(viewmanager);
            return view;

        case kSuggestedCategoryView:
            component = ComponentsFactory.getComponent(viewId,"views/SuggestedCategoryView.qml");
            view = component.createObject(viewmanager);
            return view;

        case kSuggestedUsersView:
            component = ComponentsFactory.getComponent(viewId,"views/SuggestedUsersView.qml");
            view = component.createObject(viewmanager);
            return view;

        case kUserListView:
            component = ComponentsFactory.getComponent(viewId, "views/UserListView.qml");
            view = component.createObject(viewmanager);
            return view;

        case kGalleyView:
            component = ComponentsFactory.getComponent(viewId, "views/galleryview.qml");
            view = component.createObject(viewmanager);
            return view;

        case kConversionView:
            component = ComponentsFactory.getComponent(viewId, "views/ConversionView.qml");
            view = component.createObject(viewmanager);
            return view;
	    
        case kRetweetsView:
            component = ComponentsFactory.getComponent(viewId, "views/RetweetsView.qml");
            view = component.createObject(viewmanager);
            return view;

        case kListsView:
            component = ComponentsFactory.getComponent(viewId, "views/ListsView.qml");
            view = component.createObject(viewmanager);
            return view;

        case kListsTweetsView:
            component = ComponentsFactory.getComponent(viewId, "views/ListsTweetsView.qml");
            view = component.createObject(viewmanager);
            return view;
	    
        case kDraftListView:
            component = ComponentsFactory.getComponent(viewId, "views/draftlistview.qml");
            view = component.createObject(viewmanager);
            return view;

        case kProfileLocation:
            component = ComponentsFactory.getComponent(viewId, "views/profileLocation.qml");
            view = component.createObject(viewmanager);
            return view;

        case kAboutView:
            component = ComponentsFactory.getComponent(viewId, "views/AboutView.qml");
            view = component.createObject(viewmanager);
            return view;

        default:
            break;
        }
    }

    //private functions
    function loadTokenAndUserInfo()
    {
        var token = Storage.getKeyValue("oauth_token");
        if (token !== "")
        {
            var token_secret = Storage.getKeyValue("oauth_token_secret");
            OAuth.setTokenAndSecret(token, token_secret);

            user_id = Storage.getKeyValue("user_id");
            screen_name = Storage.getKeyValue("screen_name");
            console.log("token is " + token + ", secret is " + token_secret + ", user_id is " + user_id + ", screen_name is " + screen_name);
        }
    }

    function sendUserToAuthorization(url)
    {
        var view = viewmanager.getView(kAuthWebView, true);
        view.url = url;
        viewmanager.activateView(view, viewmanager.slideLeft);
    }

    //application background
    Image {
        anchors {fill: parent}
        source: application.getImageSource("bg_paper.png");
    }

    ViewManager {
        id: viewmanager
        anchors {fill: parent}
    }

    //used by authorize.js
    HttpRequest {
        id: authorizeRequest
    }

    Component.onCompleted: {
        ComponentsFactory.initWithCapacity(kMaxViewId);
        viewmanager.activateViewById(kSplashView, viewmanager.noAnimation);
        loadTokenAndUserInfo();
    }
}
