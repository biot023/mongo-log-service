require "bootstrap"
require "services/processor"

describe "generating a time processor" do
  subject { Services::Processor.for( :time ) }
  it { should be_a( Services::Processor::Time ) }
end

describe "generating a hashes processor" do
  subject { Services::Processor.for( :hashes ) }
  it { should be_a( Services::Processor::Hashes ) }
end
