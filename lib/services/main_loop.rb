require "mongo"

module Services

  class MainLoop < Struct.new( :input_collection, :output_collection, :processors )

    def run( infinite=true )
      cursor = input_collection.collection.find( :message => { :$exists => true } )
      cursor.add_option( 1 )
      cursor.add_option( 5 )
      begin
        if cursor.has_next?
          doc = cursor.next
# TODO -- delete next line
          File.open( "log/test.log", "w+" ) { |f| f << doc.inspect << " " }
          output_collection.collection.insert( _process( doc ) )
          input_collection.collection.update( { :_id => doc["_id"] },
                                              { :$unset => { :message => true } } )
        else
# TODO -- delete next line
          File.open( "log/test.log", "w+" ) { |f| f << "Tick. " }
          sleep( 0.25 )
        end
      end while infinite
# TODO -- delete next line
      raise( "******** I should never get here ********" ) if infinite
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
