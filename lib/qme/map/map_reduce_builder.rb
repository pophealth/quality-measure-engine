module QME
  module MapReduce
    class Builder
      attr_reader :id, :parameters

      YEAR_IN_SECONDS = 365*24*60*60

      def initialize(measure_def, params)
        @measure_def = measure_def
        @id = measure_def['id']
        @parameters = {}
        measure_def['parameters'] ||= {}
        measure_def['parameters'].each do |parameter, value|
          if !params.has_key?(parameter.intern)
            raise "No value supplied for measure parameter: #{parameter}"
          end
          @parameters[parameter.intern] = params[parameter.intern]
        end
        ctx = V8::Context.new
        ctx['year']=YEAR_IN_SECONDS
        @parameters.each do |key, param|
          ctx[key]=param
        end
        measure_def['calculated_dates'] ||= {}
        measure_def['calculated_dates'].each do |parameter, value|
          @parameters[parameter.intern]=ctx.eval(value)
        end
        @property_prefix = 'this.measures["'+@id+'"].'
      end

      def map_function
        "function () {\n" +
        "  var value = {i: 0, d: 0, n: 0, e: 0};\n" +
        "  if #{population} {\n" +
        "    value.i++;\n" +
        "    if #{denominator} {\n" +
        "      value.d++;\n" +
        "      if #{numerator} {\n" +
        "        value.n++;\n" +
        "      } else if #{exception} {\n" +
        "        value.e++;\n" +
        "        value.d--;\n" +
        "      }\n" +
        "    }\n" +
        "  }\n" +
        "  emit(null, value);\n" +
        "};\n"
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

      def population
        javascript(@measure_def['population'])
      end

      def denominator
        javascript(@measure_def['denominator'])
      end

      def numerator
        javascript(@measure_def['numerator'])
      end

      def exception
        javascript(@measure_def['exception'])
      end

      def javascript(expr)
        if expr.has_key?('query')
          # leaf node
          query = expr['query']
          triple = leaf_expr(query)
          property_name = munge_property_name(triple[0])
          '('+property_name+triple[1]+triple[2]+')'
        elsif expr.size==1
          operator = expr.keys[0]
          result = logical_expr(operator, expr[operator])
          operator = result.shift
          js = '('
          result.each_with_index do |operand,index|
            if index>0
              js+=operator
            end
            js+=operand
          end
          js+=')'
          js
        elsif expr.size==0
          '(false)'
        else
          throw "Unexpected number of keys in: #{expr}"
        end
      end

      def munge_property_name(name)
        if name=='birthdate'
          'this.'+name
        else
          @property_prefix+name
        end
      end

      def logical_expr(operator, args)
        operands = args.collect { |arg| javascript(arg) }
        [get_operator(operator)].concat(operands)
      end

      def leaf_expr(query)
        property_name = query.keys[0]
        property_value_expression = query[property_name]
        if property_value_expression.kind_of?(Hash)
          operator = property_value_expression.keys[0]
          value = property_value_expression[operator]
          [property_name, get_operator(operator), get_value(value)]
        else
          [property_name, '==', get_value(property_value_expression)]
        end
      end

      def get_operator(operator)
        case operator
        when '_gt'
          '>'
        when '_gte'
          '>='
        when '_lt'
          '<'
        when '_lte'
          '<='
        when 'and'
          '&&'
        when 'or'
          '||'
        else
          throw "Unknown operator: #{operator}"
        end
      end

      def get_value(value)
        if value.kind_of?(String) && value[0]=='@'
          @parameters[value[1..-1].intern].to_s
        elsif value.kind_of?(String)
          '"'+value+'"'
        else
          value.to_s
        end
      end
    end
  end
end