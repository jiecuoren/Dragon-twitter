import QtQuick 1.0
import TwitterEngine 1.0

Item {
    id : container

    // profile API address
    property string _userProfile: "https://api.twitter.com/1/users/show.json"

    signal dataReceived(variant userObject)
    signal errorOccured()

    function requestUserInfo(aScreenName)
    {
        console.log("requestUserInfo in apiUserInfo")

        var parameters = new Array();

        parameters.push(["screen_name", aScreenName]);

        application.getOAuth().webRequest(userinfoRequest, false, _userProfile, parameters,
                                          parserUserProfile, errorCallback);
    }

    function parserUserProfile(returnData)
    {
        console.log("parserUserProfile in apiUserInfo ");
        var jsonObject = eval('(' + returnData + ')');
        container.dataReceived(jsonObject);
    }

    function errorCallback()
    {
        console.log("error in in apiUserInfo");
        container.errorOccured();
    }

    HttpRequest {
        id: userinfoRequest
    }

}
