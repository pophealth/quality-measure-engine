require 'erb'

module QME
  module MapReduce
    class Builder
      attr_reader :id, :params

      class Context
        def initialize(vars)
          vars.each do |name, value|
            instance_variable_set(('@'+name).intern, value)
          end
        end
      
        def get_binding
          binding
        end
      end

      def initialize(measure_def, params)
        @id = measure_def['id']
        @params = {}
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
          context = Context.new(@params)
          @measure_def['map_fn'] = template.result(context.get_binding)
        end
      end

      def map_function
        @measure_def['map_fn']
      end

      REDUCE_FUNCTION = <<END_OF_REDUCE_FN
function (key, values) {
  var total = {i: 0, d: 0, n: 0, e: 0};
  for (var i = 0; i < values.length; i++) {
    total.i += values[i].i;
    total.d += values[i].d;
    total.n += values[i].n;
    total.e += values[i].e;
  }
  return total;
};
END_OF_REDUCE_FN

      def reduce_function
        REDUCE_FUNCTION
      end


    end
  end
end