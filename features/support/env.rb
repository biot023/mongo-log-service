require_relative "../../lib/b23/mongo_ext/active_collection"

SERVICE_DB = "log_service_cuke"
SERVICE_NAME = "cuke_entries"

def icoll
  B23::MongoExt::ActiveCollection.new( "mongodb://localhost",
                                       SERVICE_DB, "input_#{ SERVICE_NAME }" )
end

def ocoll
  B23::MongoExt::ActiveCollection.new( "mongodb://localhost",
                                       SERVICE_DB, SERVICE_NAME )
end

Before do
  icoll.client.drop_database( SERVICE_DB )
  puts `mongo #{ SERVICE_DB } --eval "var name='#{ SERVICE_NAME }', size=1024, ttl=86400" db/reset.js`
  fail( "Existing input documents" ) if icoll.count > 0
  fail( "Existing output documents" ) if ocoll.count > 0
end
