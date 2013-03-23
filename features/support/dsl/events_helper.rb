module EventsHelper
  DATA = [ { "server" => "localhost", "level" => "debug",
             "message" => "Fearful symmetry, my dear" },
           { "server" => "localhost", "level" => "warn",
             "message" => " I Have: {\"some\"=>\"issues\"} for you" },
           { "server" => "remotehost", "level" => "warn",
             "message" => "There are: {\"Nested\"=>{\"Issues\"=>{\"In\"=>\"Here\"}}}, y'all" }
         ]

  def send_log_events( data=DATA )
    initial_count = ocoll.collection.count
    subsequent_count = initial_count + data.size
    sleep( 1 )
    icoll.collection.insert( data )
    tries = 0
    while ( ocoll.collection.count < subsequent_count ) do
      raise( "Timeout in send_log_events" ) if tries > 10
      sleep( 0.25 )
      tries += 1
    end
  end
end

World( EventsHelper )
