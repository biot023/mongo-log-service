require "optparse"
require_relative "../lib/log_service"

opts = {
  :conn            => "mongodb://localhost",
  :size            => 16777216,
  :processor_descs => []
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
  op.on( "--hashes-processor",
         "Indicate that we want to use a hashes processor" ) do |val|
    opts[:processor_descs] << :hashes
  end
end
  .parse!

LogService.new( opts[:conn],
                opts[:db],
                opts[:name],
                opts[:size],
                opts[:processor_descs] )
  .run
