import QtQuick 1.0
import "../javascript/localdata.js" as LocalDB

ListModel {
    id: model

    function doAppend( parseData )
    {
        for ( var index in parseData  )
        {
            if( typeof( parseData[index] ) === "object" )
            {
                var trendingNow = parseData[index].trends;
                console.log("trending onw length=",trendingNow.length);
                for ( var i in trendingNow )
                {
                    if( typeof( trendingNow[i] ) === "object" )
                    {
                        model.append({"query": trendingNow[i].query,
                                      "url": trendingNow[i].url,
                                      "promoted_content": trendingNow[i].promoted_content,
                                      "events": trendingNow[i].events,
                                      "mode": "public",
                                      "full_name": trendingNow[i].name } );
                        LocalDB.appendTopic(trendingNow[i].name);
                    }
                }


            }

        }
    }

    function parseReturnData( returnData )
    {
        console.log("parseReturnData");
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

