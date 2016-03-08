.pragma library
.import QtQuick.LocalStorage 2.0 as Sql
.import "enums.js" as Enums

var DB_version = "1.0"

function getDBConnection(){
    var db = Sql.LocalStorage.openDatabaseSync("TomaToDoING", DB_version, "Registry of the TomaToDoING's actions.", 10000, createDBIfNotExists);
    return db
}

function createDBIfNotExists(db){
    var tables = [
        "CREATE TABLE `Statistics` (\
            `day`	TEXT NOT NULL DEFAULT 'date(''now'',''localtime'')' PRIMARY KEY,
            `pauseTime`         INTEGER DEFAULT 0,
            `pomoTime`          INTEGER DEFAULT 0,
            `breakTime`         INTEGER DEFAULT 0,
            `savedBreakTime`	INTEGER DEFAULT 0,
            `pauseCount`        INTEGER DEFAULT 0,
            `pomoCount`         INTEGER DEFAULT 0,
            `breakCount`        INTEGER DEFAULT 0
        ) WITHOUT ROWID",
        "CREATE TABLE Registry(\
            `id`                INTEGER PRIMARY KEY,
            `day`               TEXT NOT NULL DEFAULT (date('now', 'localtime')),
            `type`              INTEGER NOT NULL,
            `start_time`        TEXT NOT NULL DEFAULT (time('now', 'localtime')),
            `end_time`          TEXT,
            `todo_uid`               TEXT
        )",
    ];
    db.transaction( function(tx) {
        for( var i in tables){
            tx.executeSql(tables[i]);
        }
    });
    db.changeVersion("", DB_version);
}

function createTodayStatisticsRow(){
    var query = "INSERT INTO Statistics(day) VALUES(date('now','localtime'))";
    db.transaction( function(tx) {
        tx.executeSql(query);
    });
}

function updateStatistics(dataObject, dayModifier){
    if(typeof dayModifier === "undefined")
        dayModifier = "0";
    var ret;
    var db = getDBConnection();
    var query = "UPDATE Statistics SET ";
    var first = true;
    for(var column in dataObject){
        if(first)
            first = false;
        else
            query += ", ";
        query += column+" = "+dataObject[column];
    }
    query += " WHERE day = date('now','localtime','"+dayModifier+"')";
    console.log("updateStatistic: ",query);
    db.transaction( function(tx) {
        ret = tx.executeSql(query);
    });
    if(ret.rowsAffected === 1)
        return true;
    else
        return false;
}

function getStatisticsRow(dayModifier){
    if(typeof dayModifier === "undefined")
        dayModifier = "0";
    var ret;
    var db = getDBConnection();
    var query = "SELECT * FROM Statistics WHERE day = date('now','localtime','"+dayModifier+"')";
    db.transaction( function(tx) {
        ret = tx.executeSql(query);
    });
    if( ret.rows.length === 0){
        return false;
    }else
        return ret.rows.item(0);
}

function insertIntoRegistry(type, todo){
    //[type]
    // 100 = pomo, 200 = pause, 300 = break, 400 = longBreak
    var ret;
    var db = getDBConnection();
    var query = "INSERT INTO Registry(type, todo_uid) VALUES (?, ?)";
    db.transaction( function(tx) {
        ret = tx.executeSql(query, [type, todo.uid]);
    });
    return ret.insertId;
}

function deleteRegistryRow(id){//Almost never executed, just nin case of rare corruptions
    var ret;
    var db = getDBConnection();
    var query = "DELETE FROM Registry WHERE id = ?";
    db.transaction( function(tx) {
        ret = tx.executeSql(query, id);
    });
}

function getUnfinishedRegistryRows(){
    var ret = [], response;
    var db = getDBConnection();
    var query = "SELECT * FROM Registry WHERE end_time IS NULL";
    db.transaction( function(tx) {
        response = tx.executeSql(query);
    });
    for(var i = 0; i < response.rows.length; i++)
        ret.push(response.rows.item(i));
    return ret;
}

function finishCurrentRegistry(id, finishedStatus, time, timeModifiers){
    //[finishedStatus]
    // 1X = cancelled X
    // 2X = earlyWellFinished X
    //where X = original type numbers (pomo,<long>Break,etc)
    var ret;
    var db = getDBConnection();
    var query = "UPDATE Registry SET ";
    if(typeof finishedStatus !== "undefined")
        query += "type = "+finishedStatus+", ";
    if(typeof time === "undefined")
        query += "end_time = time('now'";
    else
        query += "end_time = time('"+time+"'";
    if(typeof timeModifiers !== "undefined")
        for(var i in timeModifiers)
            query += ", '"+timeModifiers[i]+"'";
    query += ", 'localtime') WHERE id = " + id;
    console.log(query);
    db.transaction( function(tx) {
        ret = tx.executeSql(query);
    });
    if(ret.rowsAffected === 1)
        return true;
    else
        return false;
}

//Model functions

function start(estado, todo){
    return insertIntoRegistry(estado, todo);
}
