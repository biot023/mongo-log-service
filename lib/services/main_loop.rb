require "mongo"

module Services

  class MainLoop < Struct.new( :input_collection, :output_collection, :processors )

    def run( infinite=true )
      begin
        cursor = input_collection.find( "message" => { :$exists => true } )
        begin
          doc = cursor.next
          if doc
            output_collection.insert( _process( doc ), :w => 0 )
            input_collection.update( { "_id" => doc["_id"] },
                                     { :$unset => { "message" => true } },
                                     :w => 0 )
          else
            sleep( 0.25 ) if infinite
          end
        end while doc
      end while infinite
    end

    private

    def _process( doc )
      processors.each do |processor|
        doc = processor.process( doc )
      end
      doc
    end
  end
  
end
