require "optparse"
require_relative "../lib/log_service"

opts = {
  :conn            => "mongodb://localhost",
  :size            => 1024,
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
  op.on( "--time-processor",
         "Add a creation time field to any records without one" ) do |val|
    opts[:processor_descs] << :time
  end
  op.on( "--hashes-processor",
         "Pulls out key/value pairs into the body of the main document" ) do |val|
    opts[:processor_descs] << :hashes
  end
  op.on( "--labelled-hashes-processor",
         "Pulls out labelled hashes into a labelled sub-hash" ) do |val|
    opts[:processor_descs] << :labelled_hashes
  end
end
  .parse!

LogService.new( opts[:conn],
                opts[:db],
                opts[:name],
                opts[:size],
                opts[:processor_descs] )
  .run
