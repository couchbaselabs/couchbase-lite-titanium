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

//database.deleteDatabase();

var userId = "test1";
var userDocId = "user:" + userId;
var voteDocId = "vote:" + userId;

// Replicators
var replications = database.replicate(SYNC_URL, true);
for (var i=0; i<replications.length; i++) {
	var replication = replications[i];
	
	replication.continuous = true;
	// NOTE: There are issues w/ persistent=true during cold-start.
    replication.persistent = true;
    
    if(replication.pull) {
        replication.filter = "sync_gateway/bychannel";
        replication.query_params = {"channels":"game"};
    } else {
    	database.defineFilter("pushItems", function(properties, params) {
    		return (properties._id == userDocId || properties._id == voteDocId);
		});
		
		replication.filter = "pushItems";
    }
}

// Team
var userDoc = database.getDocument(userDocId);
if (!userDoc.currentRevision) userDoc.putProperties({});
userDoc.update(function(newRevision) {
	newRevision.putProperties({
		"team":0
	});
	
	return true;
});

// Vote
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
	Ti.API.info("### liveQuery.rowschange: " + e.source + ", " + e.source.rows + "[" + e.source.rows.count + "]");
});

/*var query = database.queryAllDocuments;
var rows = query.rows;
label.text = rows.count;
var row = rows.nextRow;
while (row) {
	Ti.API.info(row.documentID);
	row = rows.nextRow;
}*/

/*setTimeout(function() {
	CBLite.runCurrentRunLoop();
}, 100);*/

var i = 0;
setInterval(function() {
	var query = database.queryAllDocuments;
	var rows = query.rows;
	
	label.text = rows.count + " - " + ++i;
	
	/*var row = rows.nextRow;
	while (row) {
		Ti.API.info(row.documentID);
		row = rows.nextRow;
	}*/
}, 1000);

/*setInterval(function() {
	Ti.API.info("runCurrentRunLoop");
	CBLite.runCurrentRunLoop();
}, 1000);*/

//label.text = replications[0].running + ", " + replications[0].running;

try {
	//label.text = manager.directory;
	//label.text = database.name;
	//label.text = CBLite.HTTP_ERROR_DOMAIN;
	
	
} catch (e) {
	//label.text = e;
}

/*// TODO: write your module tests here
var CouchbaseLiteTitanium = require('com.couchbase.cbl');
Ti.API.info("module is => " + CouchbaseLiteTitanium);

label.text = CouchbaseLiteTitanium.example();

Ti.API.info("module exampleProp is => " + CouchbaseLiteTitanium.exampleProp);
CouchbaseLiteTitanium.exampleProp = "This is a test value";

if (Ti.Platform.name == "android") {
	var proxy = CouchbaseLiteTitanium.createExample({
		message: "Creating an example Proxy",
		backgroundColor: "red",
		width: 100,
		height: 100,
		top: 100,
		left: 150
	});

	proxy.printMessage("Hello world!");
	proxy.message = "Hi world!.  It's me again.";
	proxy.printMessage("Hello world!");
	win.add(proxy);
}*/
