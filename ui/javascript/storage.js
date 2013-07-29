//please note that the key name should be unique.
//add key names when you use this API:
//oauth_token
//oauth_token_secret
//user_id
//screen_name

// Set value to storage
function setKeyValue(key, value) {
    var db = openDatabaseSync("QmlTwitter", "1.0", "KeyValueStorage", 1024);
    db.transaction(function(tx) {
       tx.executeSql('CREATE TABLE IF NOT EXISTS ' +
                     'KeyValueStorage(keyName TEXT, textValue TEXT)');
       var rs = tx.executeSql('SELECT keyName FROM KeyValueStorage WHERE keyName = ?', [key]);
       var sql = "";
       if(rs.rows.length>0) {
           sql = "UPDATE KeyValueStorage SET textValue = ? where keyName = ?";
           tx.executeSql(sql, [value, key]);
       } else {
           sql = "INSERT INTO KeyValueStorage VALUES (?, ?)";
           tx.executeSql(sql, [key, value]);
       }
    });
}

// Get value from storage
function getKeyValue(key) {
    var ret = "";
    var db = openDatabaseSync("QmlTwitter", "1.0", "KeyValueStorage", 1024);
    db.transaction(function(tx) {
       tx.executeSql('CREATE TABLE IF NOT EXISTS KeyValueStorage(keyName TEXT, textValue TEXT)');
       var rs = tx.executeSql('SELECT * FROM KeyValueStorage WHERE keyName = ?', [key]);
       if (rs.rows.length > 0)
       {
            ret = rs.rows.item(0).textValue;
       }
    });

    return ret;
}

// clear DB
function clearDB() {
    console.log("storage clear DB");
    var db = openDatabaseSync("QmlTwitter", "1.0", "KeyValueStorage", 1024);
    db.transaction(function(tx) {
       tx.executeSql('DROP TABLE IF EXISTS KeyValueStorage');
    });
}

