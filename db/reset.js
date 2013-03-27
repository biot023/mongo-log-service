// mongo <dbname> --eval "var name='cuke_entries', size=1024, ttl=604800" build.js

var localName = typeof name === 'undefined' ? "events" : name;
var localSize = typeof size === 'undefined' ? 16384 : size;
var localTtl = typeof ttl === 'undefined' ? 86400 : ttl;
var inputName = "input_" + localName;
var delName = "del_" + inputName;

db.runCommand( { fsync: 1 } );

print( "Dropping and creating the input collection \"" + inputName + "\" ..." );
var icoll = db[inputName];
icoll.renameCollection( delName );
db.runCommand( { fsync: 1 } );
icoll.drop();
db.runCommand( { fsync: 1 } );
db.createCollection( inputName, { capped: true, size: localSize } );
db.runCommand( { fsync: 1 } );

print( "Dropping and creating the output collection \"" + localName + "\" ..." );
db[localName].remove();
db.runCommand( { fsync: 1 } );
db[localName].drop();
db.runCommand( { fsync: 1 } );
db.createCollection( localName );
var coll = db.getCollection( localName );
coll.ensureIndex( { time: 1 }, { expireAfterSeconds: localTtl } );
coll.ensureIndex( { origin: 1 } );
db.runCommand( { fsync: 1 } );

print( "Done." );
