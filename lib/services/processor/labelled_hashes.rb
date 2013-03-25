module Services
  module Processor

    class LabelledHashes

      def process( _doc )
        doc = _doc.dup
        message = doc["message"]
        while _next = _get_next( message ) do
          doc.merge!( _next.first )
          message = _next.last
        end
        doc.merge( "message" => message )
      end

      private
      def _get_next( str )
        if str =~ /([a-zA-Z0-9_]+): ?\{/
          cut, nlev = 0, 1
          $'.each_char do |char|
            if char == "{"
              nlev += 1
            elsif char == "}"
              nlev -= 1
            end
            cut += 1
            break if nlev == 0
          end
          if cut > $'.length
            nil
          else
            [ doc = { $1.downcase => eval( "{#{ $'[0, cut] }" ) }, remains = $` + $'[cut..-1] ]
          end
        else
          nil
        end
      end
    end
    
  end
end
