// mongo <dbname> --eval "var name='cuke_entries', size=1024, ttl=86400" build.js

var localName = typeof name === 'undefined' ? "events" : name;
var localSize = typeof size === 'undefined' ? 16384 : size;
var localTtl = typeof ttl === 'undefined' ? 604800 : ttl;
var inputName = "input_" + localName;

print( "Dropping and creating the input collection \"" + inputName + "\" ..." );
db[inputName].drop();
db.createCollection( inputName, { capped: true, size: localSize } );

print( "Dropping and creating the output collection \"" + localName + "\" ..." );
db[localName].drop();
db.createCollection( localName );
var coll = db.getCollection( localName );
coll.ensureIndex( { time: 1 }, { expireAfterSeconds: localTtl } );
coll.ensureIndex( { origin: 1 } );

print( "Done." );
