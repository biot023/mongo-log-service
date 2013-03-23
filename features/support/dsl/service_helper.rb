module ServiceHelper

  class Service
    attr_reader :db, :name, :opts, :cmd, :process
    
    def initialize( db, name, opts )
      @db, @name, @opts = db, name, opts
      @cmd = "bundle exec ruby bin/service.rb --db #{ @db } --name #{ @name }"
      opts.each do |key, value|
        case key
        when :bollocks then puts "Stop swearing"
        else
          raise( "Unhandled option #{ key.inspect } : #{ value.inspect }" )
        end
      end
      puts @cmd
      @process = IO.popen( @cmd )
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
          `kill -9 #{ @_service.process.pid }`
          @_service = nil
        end
      end
    end
  end

  def run_service( opts={}, name="cuke-entries", db="log-service-cuke" )
    Service.run( db, name, opts )
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
