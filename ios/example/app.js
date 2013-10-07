// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var win = Ti.UI.createWindow({
    backgroundColor:'white'
});
var label = Ti.UI.createLabel();
win.add(label);
win.open();

var SYNC_URL = "http://checkers.sync.couchbasecloud.com/checkers";

var CBLite = require('com.couchbase.cbl');
var manager = CBLite.createManager();
var database = manager.createDatabase("checkers");

// Listen for Database changes.
database.addEventListener(database.CHANGE_EVENT, function(e) {
    var query = e.source.queryAllDocuments;
    label.text = "Documents: " + query.rows.count;
});

// Get/Create unique user id.
var userId = Ti.App.Properties.getString('userId');
if (!userId) {
    userId = Titanium.Platform.createUUID();
    Ti.App.Properties.setString('userId', userId);
}

// Build document ids.
var userDocId = "user:" + userId;
var voteDocId = "vote:" + userId;

// Replicators
//
// BUG: There are issues w/ replications during cold-start.
// https://github.com/couchbase/couchbase-lite-ios/issues/150
// 
// Setting isPersistent=true causes the most issues.To work
// around this you can remove replication config (i.e. replicate
// everything) or run a few times until the exceptions stop.
var replications = database.replicate(SYNC_URL, true);
for (var i=0; i<replications.length; i++) {
    var replication = replications[i];
    
    replication.isContinuous = true;
    replication.isPersistent = true;
    
    if(replication.isPull) {
        replication.filter = "sync_gateway/bychannel";
        replication.queryParams = {"channels":"game"};
    } else {
        database.defineFilter("pushItems", function(properties, params) {
            return (properties._id == userDocId || properties._id == voteDocId);
        });
        
        replication.filter = "pushItems";
    }
}

// Update Team doc.
var userDoc = database.getDocument(userDocId);
if (!userDoc.currentRevision) userDoc.putProperties({});
userDoc.update(function(newRevision) {
    newRevision.putProperties({
        "team":0
    });
    
    return true;
});

// Update Vote doc.
var voteDoc = database.getDocument(voteDocId);
if (!voteDoc.currentRevision) voteDoc.putProperties({});
voteDoc.update(function(newRevision) {
    newRevision.putProperties({
        "game":1,
        "turn":1,
        "team":0,
        "piece":7,
        "locations":[11,15]
    });
    
    return true;
});

// Create view for games by start time.
var gamesByStartTime = database.getView("gamesByStartTime");
if (!gamesByStartTime.map) {
    gamesByStartTime.setMapAndReduce(function(doc, emitter) {
        if (doc["_id"].indexOf("game:") == 0 && doc.startTime) {
            emitter.emit(doc.startTime, doc);
        }
    }, null, "1.0");
}
// Create/observe live query for the latest game.
var liveQuery = gamesByStartTime.createQuery().toLiveQuery();
liveQuery.limit = 1;
liveQuery.descending = true;
liveQuery.addEventListener(liveQuery.CHANGE_EVENT, function(e) {
    Ti.API.info("### liveQuery.change: " + e.source + ", " + e.source.rows + "[" + e.source.rows.count + "]");
});