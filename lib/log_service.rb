require_relative "b23/mongo_ext/active_collection"
require_relative "services/processor"
require_relative "services/main_loop"

class LogService < Struct.new( :conn, :db, :name, :size, :processor_descs )

  def run
    Services::MainLoop.new( _input_collection,
                            _output_collection,
                            _processors )
      .run
  end

  private

  def _input_collection
    @_icoll ||= B23::MongoExt::ActiveCollection.new( conn, db, "input_#{ name }" )
  end

  def _output_collection
    @_ocoll ||= B23::MongoExt::ActiveCollection.new( _input_collection, name )
  end

  def _processors
    processor_descs.map { |desc| Services::Processor.for( desc ) }
  end
end
