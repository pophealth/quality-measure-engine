module QME
  module Query
    class JSONDocumentBuilder
      attr_accessor :parameters, :calculated_dates

      # Creates the JSONDocumentBuilder. Will calculate dates if parameters
      # are passed in.
      def initialize(measure_json, parameters={})
        @measure_json = measure_json
        @parameters = parameters

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
    end
  end
end
