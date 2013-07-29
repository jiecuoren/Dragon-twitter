import QtQuick 1.0
import "../components"

FlickableWebView {
    id: authWebView
    anchors.fill: parent

    //every view should have this property
    property int viewId: application.kAuthWebView
    property int deleteBehaviour: viewmanager.deleteAnyway

    //every view should define below two functions
    function handleActivation()
    {
        console.log("auth view is activated");
    }

    function handleDeactivation()
    {
        console.log("auth view is deactivated");
    }

    onUrlChanged:  {
        console.log("url changed in auth view");
        console.log("url is " + url);

        var urlStr = url.toString();
        if(-1 != urlStr.lastIndexOf("http://dragonsightforce.com"))
        {
            if (-1 != urlStr.lastIndexOf("denied"))
            {
                //user has clicked "cancel and return to app"
                viewmanager.back(viewmanager.slideRight);
                application.getOAuth().setTokenAndSecret("", "");
            }
            else
            {
                var array = urlStr.split("oauth_verifier=");
                var verifyCode = array[1].split("=");
                console.log("verifyCode is  " + verifyCode);
                application.getAuthorize().verifyCode = verifyCode;
                viewmanager.activateViewById(kMainView, viewmanager.slideLeft);
            }
        }/*
        else if (urlStr !== "https://api.twitter.com/oauth/authorize" &&
                 -1 == urlStr.lastIndexOf("oauth_token")
                 )
        {
            //user has clicked "No, thanks"
            viewmanager.back(viewmanager.slideRight);
        }*/
    }
 }


