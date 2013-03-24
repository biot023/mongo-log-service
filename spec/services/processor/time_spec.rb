require "bootstrap"
require "services/processor/time"

describe Services::Processor::Time do
  let( :service ) { described_class.new }

  describe "processing a document" do
    subject { service.process( doc ) }

    context "when the document has a time value" do
      let( :doc ) { { "time" => Time.now } }
      it { should == doc }
    end

    context "when the document has no time value of its own" do
      let( :doc ) { { "space" => "aplenty" } }
      
      it "should return the document with a time value appended" do
        Timecop.freeze do
          subject.should == doc.merge( "time" => Time.now )
        end
      end
    end
  end
  
end
