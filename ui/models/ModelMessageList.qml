import QtQuick 1.0
import "../javascript/localdata.js" as LocalDB

ListModel {
    //these two models are used to build conversion
    property ListModel allMessages: ListModel {}
    property ListModel peerProfiles: ListModel {}

    //public functions
    function parseReturnData(returnData, isReceived)
    {
        var jsonObject = eval('(' + returnData + ')');

        if ( typeof (jsonObject) === "object" )
        {
            console.log("jsonObject.length is " + jsonObject.length);
            if (0 !== jsonObject.length)
            {
                doAppend(jsonObject, isReceived);
            }

            if (!isReceived)
            {
                buildConversions();
            }
        }
    }

    //new messages are received, append it to models
    function appendNewMessages(returnData)
    {
        var jsonObject = eval('(' + returnData + ')');
        if ( typeof (jsonObject) === "object" )
        {
            //pay attention to the order!
            for (var i = jsonObject.length -1; i >= 0; --i)
            {
                //firstly, it should be saved to allMessages, for since_id purpose
                allMessages.insert(0, {"peer_user_id": jsonObject[i].sender.id_str,
                                       "created_at" : jsonObject[i].created_at,
                                       "messageText" : jsonObject[i].text,
                                       "id_str" : jsonObject[i].id_str,
                                       "isReceived" : true});

                var peer_user_id = jsonObject[i].sender.id_str;

                //search model to find the position
                var j = 0;
                for (; j < count; ++j)
                {
                    if (get(j).peer_user_id == peer_user_id)
                    {
                        get(j).conversion.append({"peer_user_id": peer_user_id,
                                                  "created_at": jsonObject[i].created_at,
                                                  "messageText": jsonObject[i].text,
                                                  "id_str": jsonObject[i].id_str,
                                                  "isReceived": true});
                        setProperty(j, "unreadFlag", true);
                        break;
                    }
                }

                if (j == count)
                {
                    //not found corresponding record, then it's a message from a new user
                    var peer_user_profile = {
                        "id_str": jsonObject[i].sender.id_str,
                        "screen_name": jsonObject[i].sender.screen_name,
                        "name": jsonObject[i].sender.name,
                        "created_at": jsonObject[i].sender.created_at,
                        "profile_image_url": jsonObject[i].sender.profile_image_url,
                        "default_profile_image": jsonObject[i].sender.default_profile_image,
                        "friends_count": jsonObject[i].sender.friends_count,
                        "followers_count": jsonObject[i].sender.followers_count,
                        "statuses_count": jsonObject[i].sender.statuses_count,
                        "favourites_count": jsonObject[i].sender.favourites_count,
                        "location": jsonObject[i].sender.location,
                        "url": jsonObject[i].sender.url,
                        "description": jsonObject[i].sender.description
                        };

                    insert(0, {"peer_user_id": peer_user_id,
                               "peer_user_profile": peer_user_profile,
                               "unreadFlag": true,
                               "conversion": [{"peer_user_id": peer_user_id,
                                               "created_at": jsonObject[i].created_at,
                                               "messageText": jsonObject[i].text,
                                               "id_str": jsonObject[i].id_str,
                                               "isReceived": true}]});

                    //save to peerProfiles
                    peerProfiles.insert(0, peer_user_profile);
                }
            }
        }
    }

    function appendSentMessage(returnData)
    {
        var jsonObject = eval('(' + returnData + ')');
        if ( typeof (jsonObject) === "object" )
        {
            //firstly, it should be saved to allMessages
            var i = 0;
            for (; i < allMessages.count; ++i)
            {
                if (!allMessages.get(i).isReceived)
                {
                    break;
                }
            }

            allMessages.insert(i, {"peer_user_id": jsonObject.recipient.id_str,
                                   "created_at" : jsonObject.created_at,
                                   "messageText" : jsonObject.text,
                                   "id_str" : jsonObject.id_str,
                                   "isReceived" : false});

            var peer_user_id = jsonObject.recipient.id_str;

            //search model to find the position
            var j = 0;
            for (; j < count; ++j)
            {
                if (get(j).peer_user_id == peer_user_id)
                {
                    get(j).conversion.append({"peer_user_id": peer_user_id,
                                              "created_at": jsonObject.created_at,
                                              "messageText": jsonObject.text,
                                              "id_str": jsonObject.id_str,
                                              "isReceived": false});

                    setProperty(j, "unreadFlag", false);
                    break;
                }
            }

            if (j == count)
            {
                //not found corresponding record, then it's a message from a new user
                var peer_user_profile = {
                        "id_str": peer_user_id,
                        "screen_name": jsonObject.recipient.screen_name,
                        "name": jsonObject.recipient.name,
                        "created_at": jsonObject.recipient.created_at,
                        "profile_image_url": jsonObject.recipient.profile_image_url,
                        "default_profile_image": jsonObject.recipient.default_profile_image,
                        "friends_count": jsonObject.recipient.friends_count,
                        "followers_count": jsonObject.recipient.followers_count,
                        "statuses_count": jsonObject.recipient.statuses_count,
                        "favourites_count": jsonObject.recipient.favourites_count,
                        "location": jsonObject.recipient.location,
                        "url": jsonObject.recipient.url,
                        "description": jsonObject.recipient.description
                        };

                insert(0, {"peer_user_id": peer_user_id,
                           "peer_user_profile": peer_user_profile,
                           "unreadFlag": false,
                           "conversion": [{"peer_user_id": peer_user_id,
                                           "created_at": jsonObject.created_at,
                                           "messageText": jsonObject.text,
                                           "id_str": jsonObject.id_str,
                                           "isReceived": false}]});

                //save to peerProfiles
                peerProfiles.insert(0, peer_user_profile);
            }
        }
    }

    function getSinceId()
    {
        return allMessages.get(0).id_str;
    }

    function deleteMessage(messageId)
    {
        //remove from allMessages
        var peer_user_id = "";
        var i = 0;
        for (; i < allMessages.count; ++i)
        {
            if (allMessages.get(i).id_str == messageId)
            {
                peer_user_id = allMessages.get(i).peer_user_id;
                allMessages.remove(i);
                console.log("removed from allMessages");
                break;
            }
        }

        //remove from this model
        for (i = 0; i < count; ++i)
        {
            if (get(i).peer_user_id == peer_user_id)
            {
                break;
            }
        }

        if (i < count)
        {
            for (var j = 0; j < get(i).conversion.count; ++j)
            {
                if (get(i).conversion.get(j).id_str == messageId)
                {
                    get(i).conversion.remove(j);
                    break;
                }
            }

            if (get(i).conversion.count === 0)
            {
                //all messages in this conversion are removed, now we should remove it
                //from this model and peerProfiles
                remove(i);
                removePeerProfile(peer_user_id);
            }
        }
    }

    function deleteMessagesOfPeerUser(peer_user_id, idsModel)
    {
        //step 1: remove related messages from allMessages
        for (var i = 0; i < allMessages.count; ++i)
        {
            if (allMessages.get(i).peer_user_id == peer_user_id)
            {
                allMessages.remove(i);
                --i;
            }
        }

        //step 2: remove profile data from peerProfiles
        removePeerProfile(peer_user_id);

        //step 3: save all the message ids to delete and remove item from this model
        idsModel.clear();
        for (var j = 0; j < count; ++j)
        {
            if (get(j).peer_user_id == peer_user_id)
            {
                for (var k = 0; k < get(j).conversion.count; ++k)
                {
                    idsModel.append({"messageId": get(j).conversion.get(k).id_str});
                }
                remove(j);
                break;
            }
        }
    }

    function getUnreadCount()
    {
        var ret = 0;
        for (var i = 0; i < count; ++i)
        {
            if (get(i).conversion.get(get(i).conversion.count - 1).isReceived && get(i).unreadFlag)
            {
                ++ret;
            }
        }

        return ret;
    }

    //private functions
    function doAppend(jsonObject, isReceived)
    {
        for (var index = 0; index < jsonObject.length; ++index)
        {
            if( typeof( jsonObject[index] ) === "object" )
            {
                allMessages.append({"peer_user_id": isReceived ? (jsonObject[index].sender.id_str) : (jsonObject[index].recipient.id_str),
                                    "created_at" : jsonObject[index].created_at,
                                    "messageText" : jsonObject[index].text,
                                    "id_str" : jsonObject[index].id_str,
                                    "isReceived" : isReceived});

                if (isReceived)
                {
                    savePeerProfileIfNotExist(jsonObject[index].sender);
                }
                else
                {
                    savePeerProfileIfNotExist(jsonObject[index].recipient);
                }
            }
        }
    }

    function savePeerProfileIfNotExist(profileData)
    {
        for (var i = 0; i < peerProfiles.count; ++i)
        {
            if (peerProfiles.get(i).id_str == profileData.id_str)
            {
                return;
            }
        }

        peerProfiles.append({"id_str" : profileData.id_str,
                             "screen_name" : profileData.screen_name,
                             "name" : profileData.name,
                             "created_at" : profileData.created_at,
                             "profile_image_url" : profileData.profile_image_url,
                             "default_profile_image" : profileData.default_profile_image,
                             "friends_count" : profileData.friends_count,
                             "followers_count" : profileData.followers_count,
                             "statuses_count" : profileData.statuses_count,
                             "favourites_count" : profileData.favourites_count,
                             "location" : profileData.location,
                             "url" : profileData.url,
                             "description" : profileData.description
                            });
        var userimgurl = (profileData.default_profile_image)? "" : profileData.profile_image_url;
        LocalDB.appendAtMeInfo(profileData.screen_name, profileData.name,
                               userimgurl, profileData.id_str);
    }

    function removePeerProfile(peer_user_id)
    {
        for (var i = 0; i < peerProfiles.count; ++i)
        {
            if (peerProfiles.get(i).id_str == peer_user_id)
            {
                console.log("removed from peerProfiles");
                peerProfiles.remove(i);
                break;
            }
        }
    }

    function buildConversions()
    {
        for (var i = 0; i < peerProfiles.count; ++i)
        {
            var user_id = peerProfiles.get(i).id_str;

            append({"peer_user_id" : peerProfiles.get(i).id_str,
                    "peer_user_profile" : peerProfiles.get(i),
                    "unreadFlag" : false,
                    "conversion" : []});

            for (var j = allMessages.count - 1; j >= 0; --j)
            {
                if (allMessages.get(j).peer_user_id == user_id)
                {
                    //order: the oldest message is at index 0
                    var insertPos = 0;
                    if (!allMessages.get(j).isReceived)
                    {
                        insertPos = get(i).conversion.count;
                    }
                    else
                    {
                        insertPos = getInsertPosition(get(i).conversion, allMessages.get(j).created_at);
                    }

                    get(i).conversion.insert(insertPos,
                                             {"peer_user_id" : allMessages.get(j).peer_user_id,
                                              "created_at" : allMessages.get(j).created_at,
                                              "messageText" : allMessages.get(j).messageText,
                                              "id_str" : allMessages.get(j).id_str,
                                              "isReceived" : allMessages.get(j).isReceived
                                             });
                }
            }
        }
    }

    //get a insert position by comparing the date
    function getInsertPosition(conversion, messageDateStr)
    {
        var messageDate = new Date(messageDateStr);
        for (var i = 0; i < conversion.count; ++i)
        {
            var otherDate = new Date(conversion.get(i).created_at);
            if (messageDate  <= otherDate)
            {
                return i;
            }
        }

        return conversion.count;
    }
}
