require_relative "processor/time"
require_relative "processor/hashes"
require_relative "processor/labelled_hashes"

module Services
  module Processor

    class << self
      def for( desc )
        case desc
        when :time
          Time.new
        when :hashes
          Hashes.new
        when :labelled_hashes
          LabelledHashes.new
        else
          raise( "Unhandled processor descriptor #{ desc.inspect }" )
        end
      end
    end
    
  end
end
