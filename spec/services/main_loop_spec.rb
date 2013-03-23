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

  describe "running the main loop" do
    let( :cursor )    { mock }
    let( :doc )       { mock }
    let( :processed ) { mock }
    subject { service.run( false ) }

    before do
      Mongo::Cursor.stub( :new ).and_return( cursor )
      cursor.stub( :next ).and_return( doc )
      service.stub( :_process ).and_return( processed )
      output_collection.collection.stub( :insert )
    end

    it "should create a tailable cursor with input collection's collection" do
      Mongo::Cursor.should_receive( :new ).with( input_collection.collection, :tailable => true )
      subject
    end

    it "should try to get the next document from the tailable cursor" do
      cursor.should_receive( :next )
      subject
    end

    it "should process the document retrieved from the cursor" do
      service.should_receive( :_process ).with( doc )
      subject
    end

    it "should insert the processed document into the output collection's collection" do
      output_collection.collection.should_receive( :insert ).with( processed )
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
