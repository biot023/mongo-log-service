require "optparse"
require_relative "../lib/log_service"

opts = {
  :conn => "mongodb://localhost",
  :size => 16777216
}

OptionParser.new do |op|
  op.banner = "Usage: ./service.rb [options]"
  op.on( "--conn [CONNECTION]",
         "The connection string to the mongodb instance" ) do |val|
    opts[:conn] = val
  end
  op.on( "--db DB",
         "The database to push log records to" ) do |val|
    opts[:db] = val
  end
  op.on( "--name NAME",
         "The name of the service (and the collection to push log records to)" ) do |val|
    opts[:name] = val
  end
  op.on( "--size [BYTES]",
         Integer,
         "The size of the input buffer table in bytes" ) do |val|
    opts[:size] = val
  end
end
  .parse!

LogService.new( conn, db, name, size ).run
