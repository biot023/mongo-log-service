require_relative "../../lib/b23/mongo_ext/active_collection"

SERVICE_DB = "log_service_cuke"
SERVICE_NAME = "cuke_entries"
puts `mongo #{ SERVICE_DB } --eval "var name='#{ SERVICE_NAME }', size=1024, ttl=86400" db/build.js`

def icoll
  B23::MongoExt::ActiveCollection.new( "mongodb://localhost",
                                       SERVICE_DB, "input_#{ SERVICE_NAME }" )
end

def ocoll
  B23::MongoExt::ActiveCollection.new( "mongodb://localhost",
                                       SERVICE_DB, SERVICE_NAME )
end
