// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// Open a single window.
var win = Ti.UI.createWindow({
    title:'Food',
    backgroundColor:'white',
    fullscreen:true
});

// Add a list view to the window.
var listView = Titanium.UI.createListView();
win.add(listView);

// Show the window.
win.open();

// TODO: To sync w/ a server database add your Sync Gateway
// url.  You can get a free developer sandbox from
// http://www.couchbasecloud.com
var SYNC_URL = null;

var CBLite = require('com.couchbase.cbl');
var manager = CBLite.createManager();
var database = manager.createDatabase('food');

// If there is a sync URL configured then set up replication.
if (SYNC_URL) {
    // BUG: There are issues w/ replications during cold-start.
    // Setting isPersistent=true causes the most issues. To work
    // around this you can remove replication config (i.e. replicate
    // everything) or run a few times until the exceptions stop.
    //
    // https://github.com/couchbase/couchbase-lite-ios/issues/150
    
    var replications = database.replicate(SYNC_URL, true);
    
    for (var i=0; i<replications.length; i++) {
        var replication = replications[i];
        
        replication.isContinuous = true;
    }
}

// Create view for food by type.
var foodByType = database.getView("foodByType");
foodByType.setMap(function(doc, emitter) {
    if (doc['_id'].indexOf('food:') == 0) {
        Ti.API.info('CBL: foodByType.emit(): ' + doc['_id']);
        
        emitter.emit([doc.type, doc.name], doc);
    }
}, "1.0");

// Create/observe live query for food.
var foodQuery = foodByType.createQuery();
var foodLiveQuery = foodQuery.toLiveQuery();
foodLiveQuery.start();
foodLiveQuery.addEventListener(foodLiveQuery.CHANGE_EVENT, function(e) {
    // BUG: There are issues w/ queries returning a row enumerator that
    // does not enumerate correctly.  For now we will just use all the
    // docs but usually this would be the event source's rows
    // i.e. showFood(e.source.rows);
    //
    // https://github.com/couchbase/couchbase-lite-ios/issues/157
    //
    showFood(database.queryAllDocuments.rows);
});

function showFood(rows) {
    var sections = {};
    
    var i=1;
    var row = rows.nextRow;
    while (row) {
        Ti.API.info('CBL: Show food[' + i + '/' + rows.count + ']: ' + row.documentId);
        
        var properties = row.document.properties;
        
        // Get unique section.
        var sectionTitle = properties.type;
        var section = sections[sectionTitle];
        if (!section) {
            section = Ti.UI.createListSection({
                headerTitle:sectionTitle
            });
            
            sections[sectionTitle] = section;
        }
        
        // Add item to section.
        section.appendItems([
            {properties: {title:properties.name}}
        ]);
        
        i++;
        row = rows.nextRow;
    }
    
    var sectionsArray = [];
    for (var section in sections) {
        sectionsArray.push(sections[section]);
    }
    
    listView.sections = sectionsArray;
}

// Init data on first run.
if (database.queryAllDocuments.rows.count == 0) {
    Ti.API.info('CBL: Init database');
    
    var foods = [
        ['Fruit','Apple'],
        ['Fruit','Banana'],
        ['Vegetable','Carrot'],
        ['Vegetable','Potatoe'],
        ['Meat', 'Beef'],
        ['Meat', 'Chicken'],
        ['Fish','Cod'],
        ['Fish','Haddock']
    ];
    
    for (var i=0; i<foods.length; i++) {
        var food = foods[i];
        var id = 'food:' + food[1];
        
        var foodDoc = database.getDocument(id);
        foodDoc.update(function(newRevision) {
            Ti.API.info('CBL: Add document: ' + newRevision.document.documentId);
            
            newRevision.putProperties({
                'type':food[0],
                'name':food[1]
            });
            
            return true;
        });
    }
}