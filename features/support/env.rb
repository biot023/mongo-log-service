require_relative "../../lib/b23/mongo_ext/active_collection"

puts `mongo log_service_cuke --eval "var name='cuke_entries', size=1048576" db/build.js`

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
