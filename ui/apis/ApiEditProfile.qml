import QtQuick 1.0
import TwitterEngine 1.0

Item {
    id: container

    property string _urlEditProfile: "http://api.twitter.com/1/account/update_profile.json"

    signal dataReceived(variant userObject)
    signal errorOccured()

    function editProfile(aModel)
    {
        var params = new Array();

        for(var index  = 0; index < aModel.count; index++)
        {
            params.push([aModel.get(index).key, aModel.get(index).value]);
        }

        application.getOAuth().webRequest(editRequest, true, _urlEditProfile,
                                          params, dataFinishedCallback,
                                          errorCallback);
    }

    function dataFinishedCallback(returnData)
    {
        console.log("api edit profile " + returnData);

        var jsonObject = eval('(' + returnData + ')');
        container.dataReceived(jsonObject);
    }

    function errorCallback(data)
    {
        console.log(data);
        errorOccured();
    }

    HttpRequest {
        id: editRequest
    }
}
