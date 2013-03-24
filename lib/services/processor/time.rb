module Services
  module Processor

    class Time

      def process( doc )
        doc.has_key?( "time" ) ? doc : doc.merge( "time" => ::Time.now )
      end
      
    end
    
  end
end
