require "fileutils"

module ServiceHelper

  class Service
    attr_reader :db, :name, :opts, :cmd, :process
    
    def initialize( db, name, opts )
      @db, @name, @opts = db, name, opts
      @cmd = "bundle exec ruby bin/service.rb --db #{ @db } --name #{ @name }"
      opts.each do |opt|
        if opt.is_a?( Hash )
          @cmd += " --#{ opt.keys.first.to_s.gsub( "_", "-" ) } #{ opt.values.first.inspect }"
        else
          @cmd += " --#{ opt.to_s.gsub( "_", "-" ) }"
        end
      end
      puts @cmd
      @process = IO.popen( @cmd )
      FileUtils.touch( "pids/#{ @process.pid }.pid" )
    end

    class << self
      def run( db, name, opts )
        if @_service
          raise( "Service #{ @_service.inspect } already running." )
        else
          new( db, name, opts )
        end
      end

      def get
        @_service || raise( "No service running" )
      end

      def stop
        if @_service
          FileUtils.rm_f( "pids/#{ @process.pid }.pid" )
          `kill -9 #{ @_service.process.pid }`
          @_service = nil
        end
      end
    end
  end

  def run_service( *opts )
    Service.run( service_dbname, service_name, opts )
  end

  def stop_service
    Service.stop
  end

  def service
    Service.get
  end
end

World( ServiceHelper )

After do
  stop_service
end

at_exit do
  Dir.glob( "pids/*.pid" ).each do |fname|
    fname =~ /^pids\/(\d+)\.pid$/
    `kill -9 #{ $1 }`
    FileUtils.rm_f( fname )
  end
end
