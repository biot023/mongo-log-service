require "optparse"
require "fileutils"
require_relative "../lib/log_service"

opts = {
  :conn            => "mongodb://localhost",
  :processor_descs => []
}

OptionParser.new do |op|
  op.banner = "Usage: ./service.rb <start|stop|restart> [options]"
  op.on( "--conn [CONNECTION]",
         "The connection string to the mongodb instance (default mongodb://localhost)" ) do |val|
    opts[:conn] = val
  end
  op.on( "--db [DB]",
         "The database to push log records to (required to start service)" ) do |val|
    opts[:db] = val
  end
  op.on( "--name NAME",
         "The name of the service (& collection to push log records to & pidfile)" ) do |val|
    opts[:name] = val
  end
  op.on( "--time-processor",
         "Add a creation time field to any records without one" ) do |val|
    opts[:processor_descs] << :time
  end
  op.on( "--ruby-safe-processor",
         "Quotes any ruby objects in message to make them safe for extraction" ) do |val|
    opts[:processor_descs] << :ruby_safe
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

pidfile = "pids/#{ opts[:name] }.pid"
command = ARGV[0]

def _dump_error( &block )
  File.open( "log/error.log", "a" ) { |file| block.call( file ) }
  block.call( STDERR )
end

def _start( opts, pidfile )
  raise( "Pidfile #{ pidfile } already exists for log service!" ) if File.exists?( pidfile )
  File.open( pidfile, "w" ) { |file| file << $$ }
  LogService.new( opts[:conn],
                  opts[:db],
                  opts[:name],
                  opts[:processor_descs] )
    .run
rescue => err
  _dump_error do |io|
    io << "******** Error in log service!\n"
    io << "Time: " << Time.now.strftime( "%Y-%m-%d %H:%M:%S" ) << "\n"
    io << "Error: " << err.class.name << "\n"
    io << "Message: " << err.message << "\n"
    io << "Backtrace:\n"
    io << err.backtrace.join( "\n" ) << "\n\n"
  end
  exit( 1 )
end

def _stop( pidfile )
  pid = File.read( pidfile ).strip
  `kill #{ pid }`
  FileUtils.rm_f( pidfile )
end

case command
when "start"
  _start( opts, pidfile )
when "stop"
  _stop( pidfile )
when "restart"
  _stop( pidfile )
  _start( opts, pidfile )
else
  _dump_error do |io|
    io << "******** Error starting log service!\n"
    io << "Unhandled command: #{ commend.inspect }\n"
    io << "Usage is:\n"
    io << "$ ruby service.rb <start|stop|restart> --name NAME <switches>"
    io << "See --help for more information."
  end
  exit( 1 )
end
