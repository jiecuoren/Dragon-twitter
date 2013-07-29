import QtQuick 1.0

ListModel {
    id: model

    function doAppend( parseData )
    {
        for ( var index in parseData  )
        {
            if( typeof( parseData[index] ) === "object" )
            {
                model.append({"full_name": parseData[index].name,
                              "slug": parseData[index].slug,
                              "mode": "public",
                              "size": parseData[index].size } );
            }

        }
    }

    function parseReturnData( returnData )
    {
        var jsonObject = eval('(' + returnData + ')');

        if ( typeof (jsonObject ) === "object" )
        {
            console.log("jsonObject.length is " + jsonObject.length);
            if( 0 !== jsonObject.length)
            {
                doAppend( jsonObject );
            }
        }
    }

}

