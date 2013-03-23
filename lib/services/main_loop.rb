require "mongo"

module Services

  class MainLoop < Struct.new( :input_collection, :output_collection, :processors )

    def run( infinite=true )
      cursor = Mongo::Cursor.new( input_collection.collection, :tailable => true )
      begin
        doc = cursor.next
        if doc
          output_collection.collection.insert( _process( doc ) )
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
