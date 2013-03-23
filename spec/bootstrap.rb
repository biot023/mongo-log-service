require "rspec"
require "timecop"
$: << File.join( File.dirname( __FILE__ ), "..", "lib" )

module CustomMatchers

  RSpec::Matchers.define( :inherit_from ) do |ancestor|
    match do |klass|
      klass.ancestors.include?( ancestor )
    end
  end
  
end

RSpec.configure do |config|
  config.include( CustomMatchers )
end
