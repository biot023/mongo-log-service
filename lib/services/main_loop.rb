require "mongo"

module Services

  class MainLoop < Struct.new( :input_collection, :output_collection, :processors )

    def run( infinite=true )
      begin
        doc = input_collection.collection.find_one( "message" => { :$exists => true } )
        if doc
          output_collection.collection.insert( _process( doc ) )
          input_collection.collection.update( { "_id" => doc["_id"] },
                                              { :$unset => { "message" => true } } )
        else
          sleep( 0.25 )
        end
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
