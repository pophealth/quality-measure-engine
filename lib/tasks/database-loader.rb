require 'json'

module QME
  module Database
    class Loader
      def initialize(db_name)
        @db_name = db_name
        @db_host = ENV['TEST_DB_HOST'] || 'localhost'
        @db_port = ENV['TEST_DB_PORT'] ? ENV['TEST_DB_PORT'].to_i : 27017
      end
      
      def get_db
        @db ||= Mongo::Connection.new(@db_host, @db_port).db(@db_name)
      end
      
      # Load a JSON file from the specified directory
      def load_json(dir_path, filename)
        file_path = File.join(dir_path, filename)
        JSON.parse(File.read(file_path))
      end
      
      # Save a JSON hash to the specified collection, creates the
      # collection if it doesn't already exist
      def save(collection_name, json)
        collection = get_db.create_collection(collection_name)
        collection.save(json)
      end
      
      def drop_collection(collection_name)
        get_db.drop_collection(collection_name)
      end
    end
  end
end