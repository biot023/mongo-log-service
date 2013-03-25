module Services
  module Processor

    class Hashes

      def process( doc )
        return doc if ! doc["message"] || doc["message"] !~ /\{/
        nest_level, cuts = 0, []
        doc["message"].each_char.each_with_index do |char, i|
          if char == "{"
            cuts << [ i ] if nest_level == 0
            nest_level += 1
          elsif char == "}"
            nest_level -= 1
            cuts.last << ( ( i - cuts.last.first ) + 1 ) if nest_level == 0
          end
        end
        fields, message = {}, ""
        cuts.inject( 0 ) do |last_i, (i, n)|
          message += doc["message"][last_i, i - last_i]
          fields.merge!( eval( doc["message"][i, n] ) )
          i + n
        end
        message += doc["message"][( cuts.last.first + cuts.last.last )..-1] if
          cuts.last && cuts.last.size == 2
        doc.merge( "message" => message ).merge( fields )
      end
      
    end
    
  end
end
