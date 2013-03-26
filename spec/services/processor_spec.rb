require "bootstrap"
require "services/processor"

describe "generating a processor" do
  { :time             => Services::Processor::Time,
    :hashes           => Services::Processor::Hashes,
    :labelled_hashes  => Services::Processor::LabelledHashes,
    :rails_controller => Services::Processor::RailsController,
    :session_id       => Services::Processor::SessionId
  }.each do |desc, klass|

    it "should create a #{ klass.inspect } for descriptor #{ desc.inspect }" do
      Services::Processor.for( desc ).should be_a( klass )
    end
    
  end
end
