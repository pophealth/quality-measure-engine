gem 'rubyzip'
require 'json'
require 'zip/zip'
require 'zip/zipfilesystem'

module QME
  module Measure
  
    # Utility class for working with JSON measure definition files
    class Loader

      # Load a measure from the filesystem
      # @param [String] measure_dir path to the directory containing a measure or measure collection document
      # @return [Array] the measures as an array of JSON measure hashes
      def self.load_measure(measure_dir)
        measures = []
        Dir.glob(File.join(measure_dir, '*.col')).each do |collection_file|
          component_dir = File.join(measure_dir, 'components')
          load_collection(collection_file, component_dir).each do |measure|
            measures << measure
          end
        end
        Dir.glob(File.join(measure_dir, '*.json')).each do |measure_file|
          files = Dir.glob(File.join(measure_dir,'*.js'))
          if files.length!=1
            raise "Unexpected number of map functions in #{measure_dir}, expected 1"
          end
          map_file = files[0]
          measure = load_measure_file(measure_file, map_file)
          measures << measure
        end
        measures
      end
      
      # Load a collection of measures definitions by processing a collection
      # definition file.
      # @param [String] collection_file path of the collection definition file
      # @param [String] component_dir path to the directory that contains the measure components
      # @return [Array] an array of measure definition JSON hashes
      def self.load_collection(collection_file, component_dir)
        collection_def = JSON.parse(File.read(collection_file))
        measure_file = File.join(component_dir, collection_def['root'])
        measures = []
        collection_def['combinations'].each do |combination|
          map_file = File.join(component_dir, combination['map_fn'])
          measure = load_measure_file(measure_file, map_file)
          # add inline metadata to top level of definition
          combination['metadata'] ||= {}
          combination['metadata'].each do |key, value|
            measure[key] = value
          end
          # add inline measure-specific properties to definition
          combination['measure'] ||= {}
          measure['measure'] ||= {}
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
      
      # For ease of development, measure definition JSON files and JavaScript 
      # map functions are stored separately in the file system, this function 
      # combines the two and returns the result
      # @param [String] measure_file path to the measure file
      # @param [String] map_fn_file path to the map function file
      # @return [Hash] a JSON hash of the measure with embedded map function.
      def self.load_measure_file(measure_file, map_fn_file)
        map_fn = File.read(map_fn_file)
        measure = JSON.parse(File.read(measure_file))
        measure['map_fn'] = map_fn
        measure
      end
      
      # Load a JSON file from the specified directory
      # @param [String] dir_path path to the directory containing the JSON file
      # @param [String] filename the JSON file
      # @return [Hash] the parsed JSON hash
      def self.load_json(dir_path, filename)
        file_path = File.join(dir_path, filename)
        JSON.parse(File.read(file_path))
      end
      
      
      def self.load_from_zip(archive, &block)
            unzip_path = "./tmp/#{Time.new.to_i}/" 
            FileUtils.mkdir_p(unzip_pa)
            all_measures = []
            Zip::ZipFile.foreach(archive) do |zipfile|
              fname = unzip_path+ zipfile.name
              FileUtils.rm fname, :force=>true
              zipfile.extract(fname)
            end
            Dir.glob(File.join(unzip_path, '*')).each do |measure_dir|
              measures = load_measure(measure_dir)  
              all_measures.concat measures
              if block_given?
                measures.for_each do |measure|
                 yield measure
                end
              end
            end
           all_measures
      end
    end
  end
end