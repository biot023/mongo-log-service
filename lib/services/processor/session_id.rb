module Services
  module Processor

    class SessionId

      def process( doc )
        if doc["message"] =~ /\bSession ID: ([a-zA-Z0-9]+)/
          doc.merge( "message"    => "#{ $` }#{ $' }",
                     "session_id" => $1 )
        else
          doc
        end
      end
      
    end
    
  end
end
