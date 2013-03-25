require "bootstrap"
require "services/processor/labelled_hashes"

describe Services::Processor::LabelledHashes do
  let( :service ) { described_class.new }

  describe "processing a document" do
    let( :input ) do
      [ { "server" => "nowhere.com", "level" => "debug", "type" => "No hashes",
          "message" => "I am a happy message { am I" },
        { "server" => "somewhere.com", "level" => "warn", "type" => "Unlabelled",
          "message" => "and {\"one\"=>\"two\"} and {\"three\"=>{\"four\"=>\"five\"}}" },
        { "server" => "everywhere.com", "level" => "fatal", "type" => "Labelled",
          "message" => "I really Hate: {\"Oblong\"=>\"Biscuits\"}" },
        { "server" => "moon.org", "level" => "error", "type" => "Nested labelled",
          "message" => "Disliking:{\"nested\"=>{\"hashes\"=>{\"On\"=>\"principle\"}}} food" },
        { "server" => "sea.change", "level" => "debug", "type" => "Two labelled",
          "message" => "I hold two: {\"Hashes\"=>\"Within\"} within:{\"my\"=>\"message\"}." }
      ]
    end
    let( :output ) do
      [ { "server" => "nowhere.com", "level" => "debug", "type" => "No hashes",
          "message" => "I am a happy message { am I" },
        { "server" => "somewhere.com", "level" => "warn", "type" => "Unlabelled",
          "message" => "and {\"one\"=>\"two\"} and {\"three\"=>{\"four\"=>\"five\"}}" },
        { "server" => "everywhere.com", "level" => "fatal", "type" => "Labelled",
          "message" => "I really ",
          "hate" => { "Oblong" => "Biscuits" } },
        { "server" => "moon.org", "level" => "error", "type" => "Nested labelled",
          "message" => " food",
          "disliking" => { "nested" => { "hashes" => { "On" => "principle" } } } },
        { "server" => "sea.change", "level" => "debug", "type" => "Two labelled",
          "message" => "I hold  .",
          "two" => { "Hashes" => "Within" },
          "within" => { "my" => "message" } }
      ]
    end
    subject { service.process( doc ) }

    it "should extract all labelled hashes out into the document, with downcase labels" do
      [ input, output ].transpose.each do |(idoc, odoc)|
        service.process( idoc ).should == odoc
      end
    end
  end
end
