import QtQuick 1.0

ListModel {
    id: model

    function doAppend( parseData )
    {
        for ( var index in parseData  )
        {
            if( typeof( parseData[index] ) === "object" )
            {
                model.append({"id": parseData[index].id_str,
                              "slug": parseData[index].slug,
                              "mode": parseData[index].mode, // mode's value is private/public
                              "name": parseData[index].name,
                              "full_name": parseData[index].full_name,
                              "subscriber_count": parseData[index].subscriber_count,
                              "member_count": parseData[index].member_count,
                              "description": parseData[index].description,
                              "following": parseData[index].following,
                              "user": parseData[index].user} );
            }

        }
    }

    function parseReturnData( returnData )
    {
        var jsonObject = eval('(' + returnData + ')');

        if ( typeof (jsonObject.lists ) === "object" )
        {
            console.log("jsonObject.length is " + jsonObject.lists.length);
            if( 0 !== jsonObject.lists.length)
            {
                doAppend( jsonObject.lists );
            }
        }
    }

}

