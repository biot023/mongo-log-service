module EventsHelper
  DATA = [ { "server" => "localhost", "level" => "debug",
             "message" => "Fearful symmetry, my dear" },
           { "server" => "localhost", "level" => "warn", "time" => Time.now,
             "message" => " I Have: {\"some\"=>\"issues\"} for you" },
           { "server" => "remotehost", "level" => "warn",
             "message" => "There are: {\"Nested\"=>{\"Issues\"=>{\"In\"=>\"Here\"}}}, y'all" }
         ]

  def send_log_events( data=DATA )
    load_id = rand( 1000000 )
    initial_count = ocoll.count
    subsequent_count = initial_count + data.size
    pause_doc = data.shuffle.first
    fail( "Already input documents in collection" ) if icoll.count > 0
    fail( "Already output documents in collection" ) if ocoll.count > 0
    data.each do |doc|
      sleep( 1 ) if doc == pause_doc
      icoll.insert( doc.merge( "load_id" => load_id ) )
    end
    tries = 0
    while ( ocoll.count < subsequent_count ) do
      raise( "Timeout in send_log_events" ) if tries > 10
      sleep( 0.25 )
      tries += 1
    end
    [ data, ocoll.find( "load_id" => load_id ).map( &:to_hash ) ]
  end
  
end

World( EventsHelper )
