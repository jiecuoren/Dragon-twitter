import QtQuick 1.0
import "../javascript/commonFunction.js" as CommonFunction
import "../javascript/localdata.js" as LocalDB

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
            console.log("jsonObject.length is " + jsonObject.length);
            if( 0 !== jsonObject.length)
            {
                doAppend( jsonObject );
                if(jsonObject.length < 20) // 20 is default value per page
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
        if (count > 0 && get(count-1).id == parseData[0].id_str)
        {
            startIndex = 1;
        }

        for (var index = startIndex; index < parseData.length; ++index)
        {
            if( typeof( parseData[index] ) === "object" )
            {
                var createAtTime = parseData[index].created_at;
                var createdDate = new Date( createAtTime );

                var media_model =''
                var user_mentions_model = ''
                var urls_model = ''
                var hashtags_model = ''
                var pos = getInsertPosition(createAtTime);

                if(typeof(parseData[index].retweeted_status) === "object")
                {
                    media_model = parseData[index].retweeted_status.entities.media;
                    user_mentions_model = parseData[index].retweeted_status.entities.user_mentions;
                    urls_model = parseData[index].retweeted_status.entities.urls;
                    hashtags_model = parseData[index].retweeted_status.entities.hashtags;
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

                    insert(pos,  {"id":parseData[index].id_str,
                                  "mini_blog_content" : parseData[index].retweeted_status.text,
                                  "created_at" : createAtTime,
                                  "created_at_short" : CommonFunction.getTimeInterval( createdDate ),
                                  "profile_image_url":parseData[index].retweeted_status.user.profile_image_url,
                                  "screen_name":parseData[index].retweeted_status.user.screen_name,
                                  "user_id":parseData[index].retweeted_status.user.id_str,
                                  "default_profile_image": parseData[index].retweeted_status.user.default_profile_image,
                                  "retweeted_by": parseData[index].user.screen_name,
                                  "name":parseData[index].retweeted_status.user.name,
                                  "user_from":parseData[index].source,
                                  "in_reply_to_screen_name":parseData[index].retweeted_status.in_reply_to_screen_name,
                                  "in_reply_to_user_id_str":parseData[index].retweeted_status.in_reply_to_user_id_str,
                                  "in_reply_to_status_id_str":parseData[index].retweeted_status.in_reply_to_status_id_str,
                                  "media":media_model,
                                  "user_mentions":user_mentions_model,
                                  "urls":urls_model,
                                  "hashtags":hashtags_model,
                                  "place":parseData[index].retweeted_status.place,
                                  "geo":parseData[index].retweeted_status.geo,
                                  "favorited":parseData[index].retweeted_status.favorited,
                                  "verified": parseData[index].retweeted_status.user.verified,
                                  "user": parseData[index].user
                           } );
                    var imgurl = (parseData[index].retweeted_status.user.default_profile_image)? "" : parseData[index].retweeted_status.user.profile_image_url;
                    LocalDB.appendAtMeInfo(parseData[index].retweeted_status.user.screen_name, parseData[index].retweeted_status.user.name,
                                           imgurl, parseData[index].retweeted_status.user.id_str);
                }
                else
                {
                    media_model = parseData[index].entities.media;
                    user_mentions_model = parseData[index].entities.user_mentions;
                    urls_model = parseData[index].entities.urls;
                    hashtags_model = parseData[index].entities.hashtags;

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

                    insert(pos,  {"id":parseData[index].id_str,
                                  "mini_blog_content" : parseData[index].text,
                                  "created_at" : createAtTime,
                                  "created_at_short" : CommonFunction.getTimeInterval( createdDate ),
                                  "profile_image_url":parseData[index].user.profile_image_url,
                                  "screen_name":parseData[index].user.screen_name,
                                  "user_id":parseData[index].user.id_str,
                                  "default_profile_image": parseData[index].user.default_profile_image,
                                  "retweeted_by": "",
                                  "name":parseData[index].user.name,
                                  "user_from":parseData[index].source,
                                  "in_reply_to_screen_name":parseData[index].in_reply_to_screen_name,
                                  "in_reply_to_user_id_str":parseData[index].in_reply_to_user_id_str,
                                  "in_reply_to_status_id_str":parseData[index].in_reply_to_status_id_str,
                                  "media":media_model,
                                  "user_mentions":user_mentions_model,
                                  "urls":urls_model,
                                  "hashtags":hashtags_model,
                                  "place":parseData[index].place,
                                  "geo":parseData[index].geo,
                                  "favorited":parseData[index].favorited,
                                  "verified": parseData[index].user.verified,
                                  "user": parseData[index].user
                           } );
                    var userimgurl = (parseData[index].user.default_profile_image)? "" : parseData[index].user.profile_image_url;
                    LocalDB.appendAtMeInfo(parseData[index].user.screen_name, parseData[index].user.name,
                                           userimgurl, parseData[index].user.id_str);
                }
            }
        }
    }
}
