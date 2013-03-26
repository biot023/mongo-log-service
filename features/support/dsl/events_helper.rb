module EventsHelper
  DATA = [ { "server" => "localhost", "level" => "debug", "type" => "Text",
             "message" => "Fearful symmetry, my dear" },
           { "server" => "localhost", "level" => "warn", "time" => Time.now, "type" => "Labelled",
             "message" => " I Have: {\"some\"=>\"issues\"} for you" },
           { "server" => "remotehost", "level" => "warn", "type" => "Labelled",
             "message" => "There are: {\"Nested\"=>{\"Issues\"=>{\"In\"=>\"Here\"}}}, y'all" },
           { "server" => "donkeyhost", "level" => "debug", "type" => "Unlabelled",
             "message" => "{\"Here\"=>\"are\"} docs {\"for\"=>{\"1\"=>{\"2\"=>\"consider\"}}}" },
           { "server" => "everywhere.com", "level" => "fatal", "type" => "Labelled",
             "message" => "I really Hate: {\"Oblong\"=>\"Biscuits\"}" },
           { "server" => "moon.org", "level" => "error", "type" => "Labelled",
             "message" => "Disliking:{\"nested\"=>{\"hashes\"=>{\"On\"=>\"principle\"}}} food" },
           { "server" => "sea.change", "level" => "debug", "type" => "Labelled",
             "message" => "I hold two: {\"Hashes\"=>\"Within\"} within:{\"my\"=>\"message\"}." },
           { "server" => "poohost", "level" => "info", "type" => "Rails",
             "message" => "Processing SessionsController#new (for 86.16.61.59 at 2013-03-25 22:49:55) [GET]\nSession ID: b298650560db8de031b590eeacb00511\nParameters: {\"controller\"=>\"sessions\", \"action\"=>\"new\"}" },
           { "server" => "doohost", "level" => "warn", "type" => "Rails",
             "message" => "Processing ItemsController#show (for 157.56.92.147 at 2013-03-25 22:49:50) [GET]\nSession ID: b14fb89ab48b9f144b76faa0402219a4\nParameters: {\"controller\"=>\"items\", \"id\"=>\"999876-Rupcycled-Bangle-Red\", \"action\"=>\"show\"}\nItem Load (0.000777)   SELECT * FROM `items` WHERE (`items`.`id` = 3546294) AND (published = '1' AND suspended_at IS NULL)\nShop Load (0.000590)   SELECT * FROM `shops` WHERE (`shops`.`id` = 130269)" },
           { "server" => "goohost", "level" => "fine", "type" => "Rails",
             "message" => "Processing IpnsController#paypal_ipn (for 173.0.81.1 at 2013-03-25 23:00:46) [POST]\nSession ID: cd02b9d27ebaa801c289791c47bfb524" }
         ]

  ROBJ_DATA = [ { "server" => "alienhost", "level" => "error", "type" => "Ruby Object",
                  "message" => "REQUESTING PAGE: POST /themes with {\"theme\"=>{\"link2_text\"=>\"\", \"name\"=>\"Valentine Gifts\", \"link2\"=>\"\", \"slug\"=>\"valentine_gifts\", \"pinterest_link\"=>\"\", \"introduction\"=>\"\", \"theme_image\"=>{\"uploaded_data\"=>#<ActionController::TestUploadedFile:0x10a268be8 @original_filename=\"square4.png\", @tempfile=#<File:/var/folders/__/b7bshk5x21x79gg7rwr7dxdh0000gn/T/square49087-0.png>, @content_type=\"image/png\">}, \"curator_username\"=>\"\", \"link\"=>\"\", \"curated_by\"=>\"\", \"link_text\"=>\"\"}, \"commit\"=>\"Create theme\"} and HTTP headers {\"HTTP_REFERER\"=>\"/themes/new\"}" }
              ]

  def send_log_events( type=:data )
    data = case type
           when :with_ruby_objects
             DATA + ROBJ_DATA
           else
             DATA
           end
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
