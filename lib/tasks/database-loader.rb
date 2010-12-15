require 'json'

module QME
  module Database
  
    # Utility class for working with JSON files and the database
    class Loader
      # Create a new Loader. Database host and port may be set using the 
      # environment variables TEST_DB_HOST and TEST_DB_PORT which default
      # to localhost and 27017 respectively.
      # @param [String] db_name the name of the database to use
      def initialize(db_name)
        @db_name = db_name
        @db_host = ENV['TEST_DB_HOST'] || 'localhost'
        @db_port = ENV['TEST_DB_PORT'] ? ENV['TEST_DB_PORT'].to_i : 27017
      end
      
      # Lazily creates a connection to the database and initializes the
      # JavaScript environment
      # @return [Mongo::Connection]
      def get_db
        if @db==nil
          @db = Mongo::Connection.new(@db_host, @db_port).db(@db_name)
          QME::MongoHelpers.initialize_javascript_frameworks(@db)
        end
        @db
      end
      
      # Create a collection of measures definitions by processing a collection
      # definition file.
      # @param [String] collection_file path of the collection definition file
      # @param [String] component_dir path to the directory that contains the measure components
      # @return [Array] an array of measure definition JSON hashes
      def create_collection(collection_file, component_dir)
        collection_def = JSON.parse(File.read(collection_file))
        measure_file = File.join(component_dir, collection_def['root'])
        measures = []
        collection_def['combinations'].each do |combination|
          map_file = File.join(component_dir, combination['map_fn'])
          measure = load_measure(measure_file, map_file) 
          combination['metadata'] ||= {}
          combination['metadata'].each do |key, value|
            measure[key] = value
          end
          combination['measure'] ||= {}
          combination['measure'].each do |key, value|
            measure['measure'][key] = value
          end
          ['population', 'denominator', 'numerator', 'exclusions'].each do |component|
            if combination[component]
              measure[component] = load_json(component_dir, combination[component])
            end
          end
          measures << measure
        end
        measures
      end
      
      # Load a measure from the filesystem and save it in the database.
      # @param [String] measure_dir path to the directory containing a measure or measure collection document
      # @param [String] collection_name name of the database collection to save the measure into.
      # @return [Array] the stroed measures as an array of JSON measure hashes
      def save_measure(measure_dir, collection_name)
        measures = []
        component_dir = File.join(measure_dir, 'components')
        Dir.glob(File.join(measure_dir, '*.col')).each do |collection_file|
          create_collection(collection_file, component_dir).each do |measure|
            measures << measure
            save(collection_name, measure)
          end
        end
        Dir.glob(File.join(measure_dir, '*.json')).each do |measure_file|
          files = Dir.glob(File.join(measure_dir,'*.js'))
          if files.length!=1
            raise "Unexpected number of map functions in #{measure_dir}, expected 1"
          end
          map_file = files[0]
          measure = load_measure(measure_file, map_file)
          measures << measure
          save(collection_name, measure)
        end
        measures
      end
      
      # For ease of development, measure definition JSON files and JavaScript 
      # map functions are stored separately in the file system, this function 
      # combines the two and returns the result
      # @param [String] measure_file path to the measure file
      # @param [String] map_fn_file path to the map function file
      # @return [Hash] a JSON hash of the measure with embedded map function.
      def load_measure(measure_file, map_fn_file)
        map_fn = File.read(map_fn_file)
        measure = JSON.parse(File.read(measure_file))
        measure['map_fn'] = map_fn
        measure
      end
      
      # Load a JSON file from the specified directory
      # @param [String] dir_path path to the directory containing the JSON file
      # @param [String] filename the JSON file
      # @return [Hash] the parsed JSON hash
      def load_json(dir_path, filename)
        file_path = File.join(dir_path, filename)
        JSON.parse(File.read(file_path))
      end
      
      # Save a JSON hash to the specified collection, creates the
      # collection if it doesn't already exist.
      # @param [String] collection_name name of the database collection
      # @param [Hash] json the JSON hash to save in the database 
      def save(collection_name, json)
        collection = get_db.create_collection(collection_name)
        collection.save(json)
      end
      
      # Drop a database collection
      # @param [String] collection_name name of the database collection
      def drop_collection(collection_name)
        get_db.drop_collection(collection_name)
      end
    end
  end
end