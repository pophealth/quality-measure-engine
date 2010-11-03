require 'json'

module QME
  module Database
    class Loader
      def initialize(db_name)
        db_host = ENV['TEST_DB_HOST'] || 'localhost'
        db_port = ENV['TEST_DB_PORT'] ? ENV['TEST_DB_PORT'].to_i : 27017
        if db_name==nil
          @db = nil
        else
         @db = Mongo::Connection.new(db_host, db_port).db(db_name)
        end
      end
      
      # Return an array of measure definitions created by processing
      # the supplied collection definition using components from the
      # supplied file directory
      def create_collection(collection_file, component_dir)
        collection_def = JSON.parse(File.read(collection_file))
        measures = []
        collection_def['combinations'].each do |combination|
          measure = load_json(component_dir, collection_def['root'])
          measure['sub_id'] = combination['sub_id']
          measure['subtitle'] = combination['subtitle']
          ['population', 'denominator', 'numerator', 'exclusions'].each do |component|
            if combination[component]
              measure[component] = load_json(component_dir, combination[component])
            end
          end
          measures << measure
        end
        measures
      end
      
      # Load a JSON file from the specified directory
      def load_json(dir_path, filename)
        file_path = File.join(dir_path, filename)
        JSON.parse(File.read(file_path))
      end
      
      # Save a JSON hash to the specified collection, creates the
      # collection if it doesn't already exist
      def save(collection_name, json)
        collection = @db.create_collection(collection_name)
        collection.save(json)
      end
      
      def drop_collection(collection_name)
        @db.drop_collection(collection_name)
      end
    end
  end
end