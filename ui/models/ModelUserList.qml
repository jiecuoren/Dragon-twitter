import QtQuick 1.0

ListModel {
    id: model

    function doAppend( parseData )
    {
        for ( var index in parseData  )
        {
            if( typeof( parseData[index] ) === "object" )
            {
                model.append({"id_str": parseData[index].id_str,
                             "screen_name": parseData[index].screen_name,
                             "name": parseData[index].name,
                             "default_profile_image": parseData[index].default_profile_image,
                             "profile_image_url": parseData[index].profile_image_url,
                             "description": parseData[index].location,
                             "url": parseData[index].url,
                             "location": parseData[index].location,
                             "followers_count": parseData[index].followers_count,
                             "statuses_count": parseData[index].statuses_count,
                             "friends_count": parseData[index].friends_count,
                             "favourites_count": parseData[index].favourites_count,
                             "following": parseData[index].following,
                             "verified": parseData[index].verified,
                             "created_at": parseData[index].created_at} );
            }
       }
    }

    function parseReturnData( returnData )
    {
        var jsonObject = eval('(' + returnData + ')');
        var canGetMoreData = true;

        if ( typeof (jsonObject ) === "object" )
        {
            console.log("jsonObject.length is " + jsonObject.length);
            if ( typeof ( jsonObject.users ) === "object" )
            {
                console.log("jsonObject.USER.length is " + jsonObject.users.length);
                if( 0 !== jsonObject.users.length)
                {
                    doAppend( jsonObject.users );
                }
                canGetMoreData = false;
            }
            else
            {
                if( 0 !== jsonObject.length)
                {
                    doAppend( jsonObject );
                    if( jsonObject.length < 20)
                    {
                        canGetMoreData = false;
                    }
                }
                else
                {
                    canGetMoreData = false;
                }
            }
        }

        return canGetMoreData;
    }
}

