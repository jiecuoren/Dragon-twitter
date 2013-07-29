import QtQuick 1.0
import "../javascript/commonFunction.js" as CommonFunction

ListModel {
    id: model

    //keep a start position to improve insert efficiency
    property int startComparePosition: 0

    //update the value of property "created_at_short" for all the items
    function updateCreatedAtShort()
    {
        for (var i = 0; i < count; ++i)
        {
            setProperty(i, "created_at_short", CommonFunction.getTimeInterval(new Date(get(i).created_at)));
        }
    }

    //get a insert position according to the creation time
    function getInsertPosition(created_at)
    {
        var createDate = new Date(created_at);
        for (var i = startComparePosition; i < count; ++i)
        {
            var otherDate = new Date(get(i).created_at);
            if (createDate >= otherDate)
            {
                break;
            }
        }

        startComparePosition = i;
        return i;
    }

    function deleteTweet( tweetId )
    {
        deleteTweetFromModel( model,tweetId );
    }

    function deleteTweetFromModel( theModel, tweetId )
    {
        for (var i = 0; i < theModel.count; ++i)
        {
            if (tweetId === theModel.get(i).id)
            {
                console.log("the tweet with id " + tweetId + " is at " + i);
                theModel.remove(i);
                break;
            }
        }
    }

    //id: the status id
    //value: true : is added to favorite
    //       false: is removed from favorite
    function updateFavoriteStatus(id, value)
    {
        updateFavoriteStatusForModel(model, id, value)
    }

    function updateFavoriteStatusForModel(theModel, id, value)
    {
        for (var i = 0; i < theModel.count; ++i)
        {
            if (id === theModel.get(i).id)
            {
                console.log("the tweet with id " + id + " is at " + i);
                theModel.setProperty(i, "favorited", value);
                break;
            }
        }
    }
}

