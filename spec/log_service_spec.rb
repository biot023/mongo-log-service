require "bootstrap"
require "log_service"

describe LogService do
  let( :conn ) { mock }
  let( :db )   { "the-db" }
  let( :name ) { "log-entries" }
  let( :size ) { 1048576 }
  let( :processor_descs ) { [ :sql, { :labelled_hash => [ "Parameters" ] } ] }
  let( :service ) { described_class.new( conn, db, name, size, processor_descs ) }

  describe "construction" do
    subject { service }
    its( :conn ) { should == conn }
    its( :db )   { should == db }
    its( :name ) { should == name }
    its( :size ) { should == size }
    its( :processor_descs ) { should == processor_descs }
  end

  describe "running the service" do
    let( :icoll )      { mock }
    let( :ocoll )      { mock }
    let( :processors ) { [ mock, mock, mock ] }
    let( :mloop )      { mock }
    subject { service.run }

    before do
      service.stub( :_input_collection ).and_return( icoll )
      service.stub( :_output_collection ).and_return( ocoll )
      service.stub( :_processors ).and_return( processors )
      Services::MainLoop.stub( :new ).and_return( mloop )
      mloop.stub( :run )
    end

    it "should get the input collection" do
      service.should_receive( :_input_collection )
      subject
    end

    it "should get the output collection" do
      service.should_receive( :_output_collection )
      subject
    end

    it "should generate the processors" do
      service.should_receive( :_processors )
      subject
    end

    it "should create a main loop service with collections and processors" do
      Services::MainLoop.should_receive( :new ).with( icoll, ocoll, processors )
      subject
    end

    it "should set the main loop service off" do
      mloop.should_receive( :run )
      subject
    end
  end

  describe "getting the input collection" do
    subject { service.send( :_input_collection ) }

    it "should create and return a capped active collection for input name" do
      B23::MongoExt::ActiveCollection.should_receive( :new )
        .with( conn, db, "input_#{ name }", :capped => true, :size => size )
        .and_return( coll = mock )
      subject.should == coll
    end
  end

  describe "getting the output collection" do
    let( :icoll ) { mock }
    let( :ocoll ) { mock }
    subject { service.send( :_output_collection ) }

    before do
      service.stub( :_input_collection ).and_return( icoll )
      B23::MongoExt::ActiveCollection.stub( :new ).and_return( ocoll )
    end

    it "should get the input collection" do
      service.should_receive( :_input_collection )
      subject
    end

    it "should create an active collection for output name and input collection" do
      B23::MongoExt::ActiveCollection.should_receive( :new ).with( icoll, name )
      subject
    end

    it "should return the new active collection" do
      subject.should == ocoll
    end
  end

  describe "getting the processors" do
    let( :processors ) { processor_descs.map { mock } }
    subject { service.send( :_processors ) }

    it "should generate and return a collection of processors for descs" do
      [ processor_descs, processors ].transpose.each do |(desc, processor)|
        Services::Processor.should_receive( :for ).with( desc ).and_return( processor )
      end
      subject.should == processors
    end
  end
  
end
