var localdb = null;
var kMaxCount = 200;

// load AtMe's info
function loadAtMeInfo(model)
{
    var ret = false;
    model.clear();
    if(localdb === null)
    {
        localdb = openDatabaseSync("QmlTwitterDB", "1.0", "local data", 1000000);
    }

    localdb.transaction(
        function(tx)
        {
            var rs = tx.executeSql('SELECT * FROM UsersInfo');
            for(var i = 0; i < rs.rows.length; i++)
            {
                model.append({ "screenName": rs.rows.item(i).screenname,
                               "name": rs.rows.item(i).name,
                               "profileImg" : rs.rows.item(i).profileimg,
                               "userId":rs.rows.item(i).userid });
                ret = true;
            }
        }
    );
    return ret;
}

// load Topic's info
function loadTopic(model)
{
    var ret = false;
    model.clear();
    if(localdb === null)
    {
        localdb = openDatabaseSync("QmlTwitterDB", "1.0", "local data", 1000000);
    }

    localdb.transaction(
        function(tx)
        {
            var rs = tx.executeSql('SELECT * FROM Topic ORDER BY text');
            for(var i = 0; i < rs.rows.length; i++)
            {
                model.append({ "topic": rs.rows.item(i).text });
                ret = true;
            }
        }
    );
    return ret;
}

// load Drafts' info
function loadDraftInfo(model)
{
    var ret = false;
    model.clear();
    if(localdb === null)
    {
        localdb = openDatabaseSync("QmlTwitterDB", "1.0", "local data", 1000000);
    }

    localdb.transaction(
        function(tx)
        {
            tx.executeSql('CREATE TABLE IF NOT EXISTS TweetDraft(title TEXT, content TEXT,'
                          + ' picurl TEXT, enableloc BIT, address TEXT, datetime TEXT)');
            var rs = tx.executeSql('SELECT * FROM TweetDraft ORDER BY datetime');
            for(var i = 0; i < rs.rows.length; i++)
            {
                model.append({ "title": rs.rows.item(i).title,
                               "content": rs.rows.item(i).content,
                               "picurl":rs.rows.item(i).picurl,
                               "enableloc":rs.rows.item(i).enableloc,
                               "address":rs.rows.item(i).address,
                               "datetime": rs.rows.item(i).datetime,
                               "showDelete": false });
                ret = true;
            }
        }
    );
    return ret;
}

function appendAtMeInfo(screenName, name, img, id)
{
    // if no name, return;
    if((0 === name.length || 0 === id.length))
    {
        return;
    }

    if(localdb === null)
    {
        localdb = openDatabaseSync("QmlTwitterDB", "1.0", "local data", 1000000);
    }

    localdb.transaction(
        function(tx)
        {
            tx.executeSql('CREATE TABLE IF NOT EXISTS UsersInfo('
                          +'screenname TEXT, name TEXT, profileimg TEXT, userid TEXT)');
            var selt = tx.executeSql('SELECT screenname FROM UsersInfo');
            if(selt.rows.length >= kMaxCount)
            {
                tx.executeSql("DELETE FROM UsersInfo WHERE screenname = ?", selt.rows.item(0).screenname);
            }

            var rs = tx.executeSql('SELECT * FROM UsersInfo WHERE screenname=?', [screenName]);
            if(rs.rows.length <= 0)
            {
                tx.executeSql('INSERT INTO UsersInfo VALUES(?, ?, ?, ?)', [screenName, name, img, id]);
            }
            else
            {
                tx.executeSql('UPDATE UsersInfo SET userid = ?, name = ?, profileimg = ? WHERE screenname=?',
                              [id, name, img, screenName]);
            }
        }
    )
}

function appendTopic(content)
{
    var str = content;
    for(;1;)
    {
        if(str.charAt(0) === '#' || str.charAt(0) === ' ')
        {
            str = str.substring(1);
        }
        else
        {
            break;
        }
    }

    if((0 === str.length))
    {
        return;
    }

    if(localdb === null)
    {
        localdb = openDatabaseSync("QmlTwitterDB", "1.0", "local data", 1000000);
    }

    localdb.transaction(
        function(tx)
        {
            tx.executeSql('CREATE TABLE IF NOT EXISTS Topic(text TEXT)');
            var selt = tx.executeSql('SELECT * FROM Topic');
            if(selt.rows.length >= kMaxCount)
            {
                tx.executeSql("DELETE FROM Topic WHERE text = ?", selt.rows.item(0).text);
            }
            var rs = tx.executeSql('SELECT * FROM Topic WHERE text=?', [str]);
            if(rs.rows.length <= 0)
            {
                tx.executeSql('INSERT INTO Topic VALUES(?)', [str]);
            }
        }
    )
}

function appendDraftInfo(title, text, url, enableloc, address, datetime)
{
    // if no content and url, return;
    if((0 === text.length) && (0 === url.length))
    {
        return;
    }

    if(localdb === null)
    {
        localdb = openDatabaseSync("QmlTwitterDB", "1.0", "local data", 1000000);
    }

    localdb.transaction(
        function(tx)
        {
            tx.executeSql('CREATE TABLE IF NOT EXISTS TweetDraft(title TEXT, content TEXT,'
                          + ' picurl TEXT, enableloc BIT, address TEXT, datetime TEXT)');
            tx.executeSql('INSERT INTO TweetDraft VALUES(?, ?, ?, ?, ?, ?)',
                          [title, text, url, enableloc, address, datetime]);
        }
    )
}

// remove one draft
function removeDraft(datetime)
{
    // if no content and url, return;
    if(0 === datetime.length)
    {
        return;
    }

    if(localdb === null)
    {
        localdb = openDatabaseSync("QmlTwitterDB", "1.0", "local data", 1000000);
    }

    localdb.transaction(
        function(tx)
        {
            tx.executeSql('DELETE FROM TweetDraft WHERE datetime = ?', [datetime]);
        }
    )
}

// update draft, update allow null content and url
// if old draft is not exists, append as a new one
function updateDraftInfo(title, text, url, enableloc, address, datetime, originaltime)
{
    // if no datatime, return;
    if(0 === datetime.length)
    {
        return;
    }

    if(localdb === null)
    {
        localdb = openDatabaseSync("QmlTwitterDB", "1.0", "local data", 1000000);
    }

    localdb.transaction(
        function(tx)
        {
            var rs = tx.executeSql('SELECT datetime FROM TweetDraft WHERE datetime = ?', [originaltime]);
            if(rs.rows.length>0)
            {
            tx.executeSql('UPDATE TweetDraft SET title = ?, content = ?, picurl = ?, '
                          + 'enableloc = ?, address = ?, datetime = ? WHERE datetime = ?',
                          [title, text, url, enableloc, address, datetime, originaltime]);
            }
            else
            {
            tx.executeSql('CREATE TABLE IF NOT EXISTS TweetDraft(title TEXT, content TEXT,'
                          + ' picurl TEXT, enableloc BIT, address TEXT, datetime TEXT)');
            tx.executeSql('INSERT INTO TweetDraft VALUES(?, ?, ?, ?, ?, ?)',
                          [title, text, url, enableloc, address, datetime]);
            }
        }
    )
}

// clear all Draft
function clearDraft()
{
    if(localdb === null)
    {
         localdb = openDatabaseSync("QmlTwitterDB", "1.0", "local data", 1000000);
    }
    localdb.transaction(
        function(tx)
        {
            tx.executeSql('DROP TABLE IF EXISTS TweetDraft');
        }
     )
}

// clear all AtMe records
function clearAtMe()
{
    if(localdb === null)
    {
         localdb = openDatabaseSync("QmlTwitterDB", "1.0", "local data", 1000000);
    }
    localdb.transaction(
        function(tx)
        {
            tx.executeSql('DROP TABLE IF EXISTS UsersInfo');
        }
     )
}

// clear all AtMe records
function clearTopic()
{
    if(localdb === null)
    {
         localdb = openDatabaseSync("QmlTwitterDB", "1.0", "local data", 1000000);
    }
    localdb.transaction(
        function(tx)
        {
            tx.executeSql('DROP TABLE IF EXISTS Topic');
        }
     )
}



