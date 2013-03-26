module Services
  module Processor

    class RubySafe

      def process( doc )
        if doc["message"] =~ /\=\>#\</
          message = doc["message"]
          while sections = _get_sections( message ) do
            message = "#{ sections[0] }\"#{ sections[1].gsub( "\"", "\\\"" ) }\"#{ sections[2] }"
          end
          doc.merge( "message" => message )
        else
          doc
        end
      end

      private
      def _get_sections( str )
        if str =~ /\=\>#(\<.*)$/
          cut, nlev, q = 0, 0, false
          $1.each_char do |char|
            if q
              q = false if char == "\""
            else
              if char == "\""
                q = true
              elsif char == "<"
                nlev += 1
              elsif char == ">"
                nlev -= 1
              end
            end
            cut += 1
            break if nlev == 0
          end
          if cut > $1.length
            nil
          else
            [ "#{ $` }=>", "##{ $1[0, cut] }", $1[cut..-1] ]
          end
        else
          nil
        end
      end
    end
    
  end
end
