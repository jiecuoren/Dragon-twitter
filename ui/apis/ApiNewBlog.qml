import QtQuick 1.0
import TwitterEngine 1.0
import "../javascript/localdata.js" as LocalDB

Item {
    id : container

    property string _newBlog : "https://api.twitter.com/1/statuses/update.json"
    property string _newBlogWithMedia : "https://upload.twitter.com/1/statuses/update_with_media.json"
    property string _geoRequest : "http://api.twitter.com/1/geo/reverse_geocode.json"

    property double latitude : 1000.0
    property double longitude : 1000.0
    property string placeId : ""
    property string placeString : ""

    signal blogPosted
    signal errorOccured
    signal localDone
    signal topicDone
    signal mapReady(string aFilePath)
    signal cameraClosed(string filePath)

    function validLatitude(lat)
    {
        if(lat >= -90.0 && lat <= 90.0)
            return true;
        return false;
    }

    function validLongitude(lon)
    {
        if(lon >= -180.0 && lon <= 180.0)
            return true;
        return false;
    }


    function openCamera()
    {
        orientation.setOrientationLandscape();
        camera.openCamera();
    }

    function setPortrait()
    {
        orientation.setOrientationPortrait();
    }

    function startLocation()
    {
        location.start(false);
    }

    function cancelLocation()
    {
        location.cancelOperation();
    }

    function errorCallback(data)
    {
        console.log("api errorCallback");
        errorOccured();
    }

    function postNewblog(content, enableLoc)
    {
        console.log("api new blog postNewblog");
        var parameters = new Array();
        parameters.push(["status", content]);
        if(validLatitude(latitude) && validLongitude(longitude) && enableLoc)
        {
            parameters.push(["lat", String(latitude)]);
            parameters.push(["long", String(longitude)]);
        }
        if(placeId != "" && enableLoc)
        {
            parameters.push(["place_id", placeId]);
        }

        parameters.push(["trim_user", "true"]);
        parameters.push(["include_entities", "true"]);

        application.getOAuth().webRequest(httpRequest, true, _newBlog, parameters, blogPostDone, errorCallback);
    }

    function postReplyblog(content, replyId, enableLoc)
    {
        var parameters = new Array();
        parameters.push(["status", content]);
        if(validLatitude(latitude) && validLongitude(longitude) && enableLoc)
        {
            parameters.push(["lat", String(latitude)]);
            parameters.push(["long", String(longitude)]);
        }

        if(placeId != "" && enableLoc)
        {
            parameters.push(["place_id", placeId]);
        }

        parameters.push(["trim_user", "true"]);
        parameters.push(["include_entities", "true"]);
        parameters.push(["in_reply_to_status_id ", replyId]);
        application.getOAuth().webRequest(httpRequest, true, _newBlog, parameters, blogPostDone, errorCallback);
    }

    function postNewblogWithMedia(content, mediaPath, enableLoc)
    {
        var parameters = new Array();
        if(validLatitude(latitude) && validLongitude(longitude) && enableLoc)
        {
            parameters.push(["lat", String(latitude)]);
            parameters.push(["long", String(longitude)]);
        }

        var filepath = new String(mediaPath);
        var patt = new RegExp("file:///", "i");
        if(filepath.search(patt) === 0)
        {
            filepath = filepath.slice(8);
            console.log(filepath);
        }

        parameters.push(["trim_user", "true"]);
        parameters.push(["include_entities", "true"]);

        application.getOAuth().upload(httpRequest,_newBlogWithMedia, parameters, content, filepath, blogPostDone, errorCallback);
    }


    function geoErrorCallback(data)
    {
        console.log("geoErrorCallback: "+data);
        placeId = "";
    }

    function getPlaceId()
    {
        if(validLatitude(latitude) && validLongitude(longitude))
        {
            var parameters = new Array();
            parameters.push(["lat", String(latitude)]);
            parameters.push(["long", String(longitude)]);
            parameters.push(["accuracy", "0"]);
            parameters.push(["granularity", "neighborhood"]);
            application.getOAuth().webRequest(geoRequest, false, _geoRequest, parameters, geoDataReceived, geoErrorCallback);
        }
    }

    function geoDataReceived(aReturnStr)
    {
        placeId = "";
        console.log("geoDataReceived");
        var jsonObject = eval('(' + aReturnStr + ')');
        if (typeof(jsonObject.result) === "object")
        {
            var data = jsonObject.result;
            var subData = data.places;
            if (typeof(subData) === "object")
            {
                placeId = subData[0].id;
                console.log("geoDataReceived" + placeId);
            }
        }
    }

    function blogPostDone(aReturnStr)
    {
        container.blogPosted();
    }

    TwtLocation {
        id: location
        onLocalDone: {
            latitude = aLat;
            longitude = aLon;
            placeId = "";
            placeString = aReturnStr;
            if(placeString !== "Unknown Place")
            {
                container.getPlaceId();
            }
            container.localDone();
        }
    }

    HttpRequest {
        id: httpRequest
    }

    HttpRequest {
        id: geoRequest
    }

    TwtOrientation {
        id: orientation
    }

    TwtCamera {
        id: camera
        onImgCaptured: {
            container.cameraClosed(aFileName);
        }
    }
}
