require "bootstrap"
require "services/processor/hashes"

describe Services::Processor::Hashes do
  let( :service ) { described_class.new }

  describe "processing a document" do
    let( :input ) do
      [ { "document" => "without", "any" => "message" },
        { "document" => "with", "message" => "", "that's" => "empty" },
        { "server" => "localhost", "level" => "debug",
          "message" => "Fearful symmetry, my dear" },
        { "server" => "localhost", "level" => "warn",
          "message" => " I Have: {\"some\"=>\"issues\"} for you" },
        { "server" => "remotehost", "level" => "warn",
          "message" => "There are: {\"Nested\"=>{\"Issues\"=>{\"In\"=>\"Here\"}}}, y'all" },
        { "server" => "donkeyhost", "level" => "debug",
          "message" => "{\"Here\"=>\"are\"} hashes {\"for\"=>{1=>{2=>\"consider\"}}}" }
      ]
    end
    let( :output ) do
      [ { "document" => "without", "any" => "message" },
        { "document" => "with", "message" => "", "that's" => "empty" },
        { "server" => "localhost", "level" => "debug",
          "message" => "Fearful symmetry, my dear" },
        { "server" => "localhost", "level" => "warn",
          "message" => " I Have:  for you",
          "some"    => "issues"
        },
        { "server" => "remotehost", "level" => "warn",
          "message" => "There are: , y'all",
          "Nested" => { "Issues" => { "In" => "Here" } }
        },
        { "server" => "donkeyhost", "level" => "debug",
          "message" => " hashes ",
          "Here" => "are",
          "for" => { 1 => { 2 => "consider" } }
        }
      ]
    end

    it "should extract all keys and values out into the main document" do
      [ input, output ].transpose.each do |idoc, odoc|
        service.process( idoc ).should == odoc
      end
    end
  end
end
