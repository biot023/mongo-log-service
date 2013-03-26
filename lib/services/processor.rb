require_relative "processor/time"
require_relative "processor/ruby_safe"
require_relative "processor/hashes"
require_relative "processor/labelled_hashes"
require_relative "processor/rails_controller"
require_relative "processor/session_id"

module Services
  module Processor

    class << self
      def for( desc )
        const_get( desc.to_s.gsub( /(?:^|_)(.)/ ) { |m| $1.upcase } ).new
      end
    end
    
  end
end
