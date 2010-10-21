module QME
  module MapReduce
    class Builder
      def initialize(measure_def, params)
        @measure_def = measure_def
        @measure = QME::Measure.new(measure_def, params)
        @property_prefix = 'measures.'+@measure.id+'.'
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
          @property_prefix+triple[0]+triple[1]+triple[2]
        else
          # logical operator $and, $or etc
          ''
        end
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
        when '$gt'
          '>'
        when '$gte'
          '>='
        when '$lt'
          '<'
        when '$lte'
          '<='
        else
          throw "Unknown operator: #{operator}"
        end
      end

      def get_value(value)
        if value.kind_of?(String) && value[0] = '@'
          @measure.parameters[value[1..-1].intern].value.to_s
        else
          value.to_s
        end
      end
    end
  end
end