require "bootstrap"
require "services/main_loop"

describe Services::MainLoop do
  let( :input_collection )  { mock }
  let( :output_collection ) { mock }
  let( :processors )        { [ mock, mock ] }
  let( :service ) { described_class.new( input_collection, output_collection, processors ) }

  describe "construction" do
    subject { service }
    its( :input_collection )  { should == input_collection }
    its( :output_collection ) { should == output_collection }
    its( :processors )        { should == processors }
  end

  describe "running the main loop for one iteration" do
    let( :entries )           { [ { "_id" => "abc123" }, { "_id" => "def456" } ] }
    let( :processed_entries ) { entries.map { mock } }
    subject { service.run( false ) }

    before do
      input_collection.stub( :find ).and_return( entries )
      entries.stub( :next ).and_return( *( entries + [ nil ] ) )
      service.stub( :_process ).and_return( *processed_entries )
      output_collection.stub( :insert )
      input_collection.stub( :update )
    end

    it "should get any entries with messages to process from the input collection" do
      input_collection.should_receive( :find ).with( "message" => { :$exists => true } )
      subject
    end

    it "should process each entry retrieved" do
      [ entries, processed_entries ].transpose.each do |(entry, processed_entry)|
        service.should_receive( :_process ).with( entry ).and_return( processed_entry )
      end
      subject
    end

    it "should insert the processed entries to the output collection" do
      processed_entries.each do |processed_entry|
        output_collection.should_receive( :insert ).with( processed_entry, :w => 0 )
      end
      subject
    end

    it "should remove the message from the input entries" do
      entries.each do |entry|
        input_collection.should_receive( :update )
          .with( { "_id" => entry["_id"] },
                 { :$unset => { "message" => true } },
                 :w => 0 )
      end
      subject
    end
  end

  describe "processing a document" do
    let( :doc )       { mock }
    let( :processed ) { processors.map { mock } }
    subject { service.send( :_process, doc ) }

    it "should run each processor on the doc and return the cumulative result" do
      [ processors, processed ].transpose.inject( doc ) do |last, (processor, this)|
        processor.should_receive( :process ).with( last ).and_return( this )
        this
      end
      subject.should == processed.last
    end
  end
  
end
