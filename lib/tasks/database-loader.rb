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
      
      # Return an array of measure definitions created by processing
      # the supplied collection definition using components from the
      # supplied file directory
      def create_collection(collection_file, component_dir)
        collection_def = JSON.parse(File.read(collection_file))
        measures = []
        collection_def['combinations'].each do |combination|
          measure_file = File.join(component_dir, collection_def['root'])
          map_file = File.join(component_dir, combination['map_fn'])
          measure = load_measure(measure_file, map_file) 
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
      
      # Load a measure file and map function from the specified directory
      def load_measure(measure_file, map_fn_file)
        map_fn = File.read(map_fn_file)
        measure = JSON.parse(File.read(measure_file))
        measure['map_fn'] = map_fn
        measure
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