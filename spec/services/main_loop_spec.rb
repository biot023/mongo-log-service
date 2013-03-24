require "bootstrap"
require "services/main_loop"

describe Services::MainLoop do
  let( :input_collection )  { mock( :collection => mock ) }
  let( :output_collection ) { mock( :collection => mock ) }
  let( :processors )        { [ mock, mock ] }
  let( :service ) { described_class.new( input_collection, output_collection, processors ) }

  describe "construction" do
    subject { service }
    its( :input_collection )  { should == input_collection }
    its( :output_collection ) { should == output_collection }
    its( :processors )        { should == processors }
  end

  describe "running the main loop for one iteration" do
    let( :input_doc )     { { "_id" => "abc123" } }
    let( :processed_doc ) { mock }
    subject { service.run( false ) }

    before do
      input_collection.stub( :find_one ).and_return( input_doc )
      service.stub( :_process ).and_return( processed_doc )
      output_collection.stub( :insert )
      input_collection.stub( :update )
    end

    it "should find the first input doc with a message" do
      input_collection.should_receive( :find_one )
        .with( "message" => { :$exists => true } )
      subject
    end

    it "should process the input doc" do
      service.should_receive( :_process ).with( input_doc )
      subject
    end

    it "should insert the processed doc to the output collection" do
      output_collection.should_receive( :insert ).with( processed_doc )
      subject
    end

    it "should unset the message field from the input doc" do
      input_collection.should_receive( :update )
        .with( { "_id" => input_doc["_id"] }, { :$unset => { "message" => true } } )
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
