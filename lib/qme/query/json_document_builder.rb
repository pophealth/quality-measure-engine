module QME
  module Query
    class JSONDocumentBuilder
      attr_accessor :parameters, :calculated_dates

      # Creates the JSONDocumentBuilder. Will calculate dates if parameters
      # are passed in.
      def initialize(measure_json, parameters={})
        @measure_json = measure_json
        @parameters = parameters
        @measure_id = measure_json['id']

        if ! parameters.empty?
          calculate_dates
        end
      end

      # Calculates all dates necessary to create a query for this measure
      # This will be run by the constructor if params were passed in
      def calculate_dates
        ctx = V8::Context.new
        @parameters.each_pair do |key, value|
          ctx[key] = value
        end

        ctx['year'] = 365 * 24 * 60 * 60 # TODO: Replace this with a js file that has all constants

        @calculated_dates = {}
        @measure_json["calculated_dates"].each_pair do |key, value|
          @calculated_dates[key] = ctx.eval(value)
        end
      end

      # Creates the appropriate JSON document to query MongoDB based on
      # a measure definition passed in. This method calls itself recursively
      # to walk the tree and get all possible logical operators available
      # in a measure definition
      def create_query(definition_json, args={})
        if definition_json.has_key?('and')
          definition_json['and'].each do |operand|
            create_query(operand, args)
          end
        elsif definition_json.has_key?('or')
          operands = []
          definition_json['or'].each do |operand|
            operands << create_query(operand)
          end
          args['$or'] = operands
        elsif definition_json.has_key?('query')
          process_query(definition_json['query'], args)
        end

        args
      end

      # Called by create_query to process leaf nodes in a measure
      # definition
      def process_query(definition_json, args)
        if definition_json.size > 1
          raise 'A query should have only one property'
        end

        query_property = definition_json.keys.first
        document_key = transform_query_property(query_property)
        document_value = nil
        query_value = definition_json[query_property]
        if query_value.kind_of?(Hash)
          if query_value.size > 1
            raise 'A query value should only have one property'
          end

          document_value = {query_value.keys.first.gsub('_', '$') =>
                            substitute_variables(query_value.values.first)}
          if args[document_key]
            args[document_key].merge!(document_value)
          else
            args[document_key] = document_value
          end
        else
          document_value = substitute_variables(query_value)
          args[document_key] = document_value
        end
      end
      
      # Takes a query property name and transforms it into
      # a name of a key in a MongoDB document
      def transform_query_property(property_name)
        #TODO What do we do with special case fields - the stuff we are keeping at the patient level?
        if ['birthdate'].include?(property_name)
          property_name
        else
          "measures.#{@measure_id}.#{property_name}"
        end
      end

      # Finds strings that start with "@" and replaces them
      # with the calculated date
      def substitute_variables(value)
        if value.kind_of?(String) && value[0] == '@'
          variable_name = value[1..-1]
          @calculated_dates[variable_name]
        else
          value
        end
      end
    end
  end
end
