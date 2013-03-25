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

describe "generating a labelled hashes processor" do
  subject { Services::Processor.for( :labelled_hashes ) }
  it { should be_a( Services::Processor::LabelledHashes ) }
end
