require 'erb'
require 'ostruct'

module QME
  module MapReduce
  
    # Builds Map and Reduce functions for a particular measure
    class Builder
      attr_reader :id, :params

      # Utility class used to supply a binding to Erb
      class Context < OpenStruct
        # Create a new context
        # @param [Hash] vars a hash of parameter names (String) and values (Object). Each entry is added as an accessor of the new Context
        def initialize(db, vars)
          super(vars)
          @db = db
        end
      
        # Get a binding that contains all the instance variables
        # @return [Binding]
        def get_binding
          binding
        end
        
        def init_js_frameworks
          result = ''
          result << 'if (typeof(map)=="undefined") {'
          result << "\n"
          Dir.glob(File.join(File.dirname(__FILE__), '../../../js/*.js')).each do |js_file|
            result << File.read(js_file)
            result << "\n"
          end
          Dir.glob(File.join('./js/*.js')).each do |js_file|
            result << File.read(js_file)
            result << "\n"
          end
          @db['bundles'].find.each do |bundle|
            (bundle['extensions'] || []).each do |ext|
              result << ext
              result << "\n"
            end
          end
          result << "}\n"
          result
        end
      end

      # Create a new Builder
      # @param [Hash] measure_def a JSON hash of the measure, field values may contain Erb directives to inject the values of supplied parameters into the map function
      # @param [Hash] params a hash of parameter names (String or Symbol) and their values
      def initialize(db, measure_def, params)
        @id = measure_def['id']
        @params = {}
        @db = db
        
        # normalize parameters hash to accept either symbol or string keys
        params.each do |name, value|
          @params[name.to_s] = value
        end
        @measure_def = measure_def
        @measure_def['parameters'] ||= {}
        @measure_def['parameters'].each do |parameter, value|
          if !@params.has_key?(parameter)
            raise "No value supplied for measure parameter: #{parameter}"
          end
        end
        # if the map function is specified then replace any erb templates with their values
        # taken from the supplied params
        # always true for actual measures, not always true for unit tests
        if (@measure_def['map_fn'])
          template = ERB.new(@measure_def['map_fn'])
          context = Context.new(@db, @params)
          @measure_def['map_fn'] = template.result(context.get_binding)
        end
      end

      # Get the map function for the measure
      # @return [String] the map function
      def map_function
        @measure_def['map_fn']
      end

      # Get the reduce function for the measure, this is a simple
      # wrapper for the reduce utility function specified in
      # map-reduce-utils.js
      # @return [String] the reduce function
      def reduce_function
        'function (key, values) { return reduce(key, values);};'
      end


    end
  end
end