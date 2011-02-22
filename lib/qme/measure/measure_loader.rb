gem 'rubyzip'
require 'json'
require 'zip/zip'
require 'zip/zipfilesystem'
require File.join(File.dirname(__FILE__),'properties_builder')

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
      
      # For ease of development and change mananegment, measure definition JSON
      # files, property lists and JavaScript map functions are stored separately
      # in the file system, this function combines the three components and 
      # returns the result.
      # @param [String] measure_file path to the measure file
      # @param [String] map_fn_file path to the map function file
      # @return [Hash] a JSON hash of the measure with embedded map function.
      def self.load_measure_file(measure_file, map_fn_file)
        map_fn = File.read(map_fn_file)
        measure = JSON.parse(File.read(measure_file))
        measure['map_fn'] = map_fn
        if measure['properties']
          measure_props_file = File.join(ENV['MEASURE_PROPS'], measure['properties'])
          measure_props = JSON.parse(File.read(measure_props_file))
          if measure_props['measure']
            # copy measure properties over
            measure['measure'] = measure_props['measure']
          else
            # convert JSONified XLS to properties format and add to measure
            measure['measure'] = QME::Measure::PropertiesBuilder.get_properties(measure_props, measure_props_file)
          end
        end
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
      
      
      #Load a bundle from a directory
      #@param [String] bundel_path path to directory containing the bundle information
      
      def self.load_bundle(bundle_path)
        bundle = {};
        bundle_file = File.join(bundle_path,'bundle.js')
        
        bundle[:bundle_data] =  File.exists?(bundle_file) ? JSON.parse(File.read(bundle_file)) : JSON.parse("{}")
        bundle[:bundle_data][:extensions] = load_bundle_extensions(bundle_path)
        bundle[:measures] = []
        Dir.glob(File.join(bundle_path, 'measures', '*')).each do |measure_dir|
          load_measure(measure_dir).each do |measure|
            bundle[:measures] << measure
          end
        end
        bundle
      end
      
      
      # Load all of the extenson functions that will be available to map reduce functions from the bundle dir
      # This will load from bundle_path/js and from ext directories in the individule measures directories 
      # like bundle_path/measures/0001/ext/ 
      #@param [String] bundle_path the path to the bundle directory
      def self.load_bundle_extensions(bundle_path)
        extensions = []
        Dir.glob(File.join(bundle_path, 'js', '*.js')).each do |js_file|
          raw_js = File.read(js_file)
           extensions << raw_js
        end
        Dir.glob(File.join(bundle_path, 'measures', '*','ext', '*.js')).each do |js_file|
          raw_js = File.read(js_file)
          extensions << raw_js
        end
        extensions
      end
      
      
      def self.load_from_zip(archive)
            unzip_path = "./tmp/#{Time.new.to_i}/" 
            FileUtils.mkdir_p(unzip_path)
            all_measures = []
            Zip::ZipFile.foreach(archive) do |zipfile|
              fname = unzip_path+ zipfile.name
              FileUtils.rm fname, :force=>true
              zipfile.extract(fname)
            end
           load_bundle(unzip_path)
      end
    end
  end
end