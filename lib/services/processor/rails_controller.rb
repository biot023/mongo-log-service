module Services
  module Processor

    class RailsController

      def process( doc )
        if doc["message"] && doc["message"] =~
            /^Processing ([a-zA-Z0-9]+)#([a-z0-9_]+) \(for ([0-9\.]+).*\[([A-Z]+)\]/
          doc.merge( "message"    => $',
                     "controller" => $1,
                     "action"     => $2,
                     "ip_address" => $3,
                     "http_verb"  => $4 )
        else
          doc
        end
      end
      
    end
    
  end
end
