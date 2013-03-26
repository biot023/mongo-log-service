require "bootstrap"
require "services/processor/session_id"

describe Services::Processor::SessionId do
  let( :service ) { described_class.new }

  describe "processing a document" do
    let( :input ) do
      [ { "server" => "moo.cow", "level" => "improbable", "type" => "No Message" },
        { "server" => "sea.change", "level" => "debug", "type" => "Labelled",
          "message" => "I hold two: {\"Hashes\"=>\"Within\"} within:{\"my\"=>\"message\"}." },
        { "server" => "poohost", "level" => "info", "type" => "Rails",
          "message" => "Processing SessionsController#new (for 86.16.61.59 at 2013-03-25 22:49:55) [GET]\nSession ID: b298650560db8de031b590eeacb00511\nParameters: {\"controller\"=>\"sessions\", \"action\"=>\"new\"}" },
        { "server" => "doohost", "level" => "warn", "type" => "Rails",
          "message" => "Processing ItemsController#show (for 157.56.92.147 at 2013-03-25 22:49:50) [GET]\nSession ID: b14fb89ab48b9f144b76faa0402219a4\nParameters: {\"controller\"=>\"items\", \"id\"=>\"999876-Rupcycled-Bangle-Red\", \"action\"=>\"show\"}\nItem Load (0.000777)   SELECT * FROM `items` WHERE (`items`.`id` = 3546294) AND (published = '1' AND suspended_at IS NULL)\nShop Load (0.000590)   SELECT * FROM `shops` WHERE (`shops`.`id` = 130269)" },
        { "server" => "goohost", "level" => "fine", "type" => "Rails",
          "message" => "Processing IpnsController#paypal_ipn (for 173.0.81.1 at 2013-03-25 23:00:46) [POST]\nSession ID: cd02b9d27ebaa801c289791c47bfb524" }
      ]
    end
    let( :output ) do
      [ { "server" => "moo.cow", "level" => "improbable", "type" => "No Message" },
        { "server" => "sea.change", "level" => "debug", "type" => "Labelled",
          "message" => "I hold two: {\"Hashes\"=>\"Within\"} within:{\"my\"=>\"message\"}." },
        { "server" => "poohost", "level" => "info", "type" => "Rails",
          "message" => "Processing SessionsController#new (for 86.16.61.59 at 2013-03-25 22:49:55) [GET]\n\nParameters: {\"controller\"=>\"sessions\", \"action\"=>\"new\"}",
          "session_id" => "b298650560db8de031b590eeacb00511" },
        { "server" => "doohost", "level" => "warn", "type" => "Rails",
          "message" => "Processing ItemsController#show (for 157.56.92.147 at 2013-03-25 22:49:50) [GET]\n\nParameters: {\"controller\"=>\"items\", \"id\"=>\"999876-Rupcycled-Bangle-Red\", \"action\"=>\"show\"}\nItem Load (0.000777)   SELECT * FROM `items` WHERE (`items`.`id` = 3546294) AND (published = '1' AND suspended_at IS NULL)\nShop Load (0.000590)   SELECT * FROM `shops` WHERE (`shops`.`id` = 130269)",
          "session_id" => "b14fb89ab48b9f144b76faa0402219a4" },
        { "server" => "goohost", "level" => "fine", "type" => "Rails",
          "message" => "Processing IpnsController#paypal_ipn (for 173.0.81.1 at 2013-03-25 23:00:46) [POST]\n",
          "session_id" => "cd02b9d27ebaa801c289791c47bfb524" }
      ]
    end

    it "should pull out the session ids of those records with them" do
      [ input, output ].transpose.each do |(idoc, odoc)|
        service.process( idoc ).should == odoc
      end
    end
  end
  
end
