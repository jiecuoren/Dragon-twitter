import QtQuick 1.0
import TwitterEngine 1.0
import "../models"

Item {
    id : container

    property string _trendingNow: "https://api.twitter.com/1/trends/1.json"

    signal dataReceived()
    signal errorOccured()

    function getTrendingNow()
    {
        console.log("api getTrendingNow");

        application.getOAuth().webRequest(trendingNowRequest, false, _trendingNow, "",
                                                      trendingNowRecevied, errorCallback);


    }

    function errorCallback(data)
    {
        console.log("error in getTrendingNow" + data);
        errorOccured();
    }

    function trendingNowRecevied( aReturnStr )
    {
        trendingNowModel.clear();
        trendingNowModel.parseReturnData( aReturnStr );
        container.dataReceived();
    }

    HttpRequest {
        id: trendingNowRequest
    }

}

