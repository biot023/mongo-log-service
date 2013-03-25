require_relative "../../lib/b23/mongo_ext/active_collection"

def service_dbname
  @@service_dbname ||= "log_service_cuke"
end

def service_name
  "cuke_entries"
end

def icoll
  B23::MongoExt::ActiveCollection.new( "mongodb://localhost",
                                       service_dbname, "input_#{ service_name }" )
end

def ocoll
  B23::MongoExt::ActiveCollection.new( "mongodb://localhost",
                                       service_dbname, service_name )
end

Before do
  $instance ||= -1
  $instance += 1
  @@service_dbname = "log_service_cuke_#{ $instance }"
  icoll.client.drop_database( service_dbname )
  puts `mongo #{ service_dbname } --eval "var name='#{ service_name }', size=1024, ttl=86400" db/reset.js`
  fail( "Existing input documents" ) if icoll.count > 0
  fail( "Existing output documents" ) if ocoll.count > 0
end

at_exit do
  client = Mongo::MongoClient.from_uri( "mongodb://localhost" )
  ( $instance + 1 ).times do |i|
    dbname = "log_service_cuke_#{ i }"
    puts client.drop_database( dbname )
  end
end
