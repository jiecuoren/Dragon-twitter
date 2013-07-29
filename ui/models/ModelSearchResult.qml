import QtQuick 1.0
import "../javascript/commonFunction.js" as CommonFunction

ModelBlogListBase {
    id: model

    function parseReturnData( returnData )
    {
        console.log("parseReturnData start");
        startComparePosition = 0;

        var canGetMoreData = true;
        var jsonObject = eval('(' + returnData + ')');

        if ( typeof (jsonObject ) === "object" )
        {
            console.log("jsonObject.length is " + jsonObject.results.length);

            if( 0 !== jsonObject.results.length)
            {
                doAppend( jsonObject );
                if( jsonObject.results.length < 20) // 20 is default value per page
                {
                    canGetMoreData = false;
                }
            }
            else
            {
                canGetMoreData = false;
            }
        }

        console.log("parseReturnData end");
        return canGetMoreData;
    }


    function doAppend( parseData )
    {
        var startIndex = 0;
        //when use max_id to get next page, the first one is repeated
        if (count > 0 && get(count-1).id == parseData.results[0].id_str)
        {
            startIndex = 1;
        }

        for (var index = startIndex; index < parseData.results.length; ++index)
        {
            if( typeof( parseData.results[index] ) === "object" )
            {
                var createAtTime = parseData.results[index].created_at;
                var createdDate = new Date( createAtTime );

                var media_model =''
                var user_mentions_model = ''
                var urls_model = ''
                var hashtags_model = ''
                var pos = getInsertPosition(createAtTime);

                if(typeof(parseData.results[index].entities) === "object")
                {
                     media_model = parseData.results[index].entities.media;
                     user_mentions_model = parseData.results[index].entities.user_mentions;
                     urls_model = parseData.results[index].entities.urls;
                     hashtags_model = parseData.results[index].entities.hashtags;
                    if ( typeof( media_model) === "undefined" )
                    {
                        media_model = [];
                    }

                    if ( typeof( user_mentions_model) === "undefined" )
                    {
                        user_mentions_model = [];
                    }

                    if ( typeof( urls_model) === "undefined" )
                    {
                        urls_model = [];
                    }

                    if ( typeof( hashtags_model) === "undefined" )
                    {
                        hashtags_model = [];
                    }

                    insert(pos,  {"id":parseData.results[index].id_str,
                                  "mini_blog_content" : parseData.results[index].text,
                                  "created_at" : createAtTime,
                                  "created_at_short" : CommonFunction.getTimeInterval( createdDate ),
                                  "profile_image_url":parseData.results[index].profile_image_url,
                                  "screen_name":parseData.results[index].from_user,
                                  "user_id" : parseData.results[index].from_user_id_str,
                                  "default_profile_image": false,
                                  "retweeted_by": "",
                                  "name": "",
                                  "user_from":CommonFunction.convert( parseData.results[index].source ),
                                  "in_reply_to_screen_name": "",
                                  "in_reply_to_user_id_str": "",
                                  "in_reply_to_status_id_str": "",
                                  "media":media_model,
                                  "user_mentions":user_mentions_model,
                                  "urls":urls_model,
                                  "hashtags":hashtags_model,
                                  "geo":parseData.results[index].geo,
                                  "favorited": false,
                                  "verified": false,
                                  "user": { id_str: parseData.results[index].id_str,
                                               profile_image_url: parseData.results[index].profile_image_url,
                                               name: parseData.results[index].from_user,
                                               screen_name: parseData.results[index].from_user,
                                               default_profile_image: false}
                           } );
                }
            }
        }
    }
}
