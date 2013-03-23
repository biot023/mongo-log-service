require "mongo"

module B23
  module MongoExt

    class ActiveCollection
      attr_reader :connstr, :dbname, :name

      def initialize( *args )
        if args.first.is_a?( ActiveCollection )
          @connstr, @dbname, @client, @db =
            args.first.connstr, args.first.dbname, args.first.client, args.first.db
          @name = args[1]
          create_options = args[2]
        else
          @connstr, @dbname, @name, create_options = *args
        end
        db.create_collection( name, create_options ) if create_options
      end

      def client
        @client = Mongo::MongoClient.from_uri( connstr ) if ! @client || ! @client.active?
        @client
      end

      def db
        @db = client.db( dbname ) if ! @db || ! @client.active?
        @db
      end

      def collection
        @collection = db.collection( name ) if ! @collection || ! @client.active?
        @collection
      end
    end
    
  end
end
