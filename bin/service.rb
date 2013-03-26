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
         "The connection string to the mongodb instance (default mongodb://localhost)" ) do |val|
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
         "The size of the input buffer table in bytes (default 1024)" ) do |val|
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
  op.on( "--rails-controller-processor",
         "Pulls out rails controller information into the main document" ) do |val|
    opts[:processor_descs] << :rails_controller
  end
  op.on( "--session-id-processor",
         "Pulls out session id information into the main document" ) do |val|
    opts[:processor_descs] << :session_id
  end
end
  .parse!

begin
  LogService.new( opts[:conn],
                  opts[:db],
                  opts[:name],
                  opts[:size],
                  opts[:processor_descs] )
    .run
rescue => err
  dump_to = lambda do |io|
    io << "******** Error in log service!\n"
    io << "Time: " << Time.now.strftime( "%Y-%m-%d %H:%M:%S" ) << "\n"
    io << "Error: " << err.class.name << "\n"
    io << "Message: " << err.message << "\n"
    io << "Backtrace:\n"
    io << err.backtrace.join( "\n" ) << "\n\n"
  end
  File.open( "log/error.log", "a" ) { |file| dump_to.call( file ) }
  dump_to.call( STDERR )
  exit( 1 )
end
