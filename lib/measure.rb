module Engine

  SUPPORTED_PROPERTY_TYPES = {'long'=>:long, 'boolean'=>:boolean}
  class << SUPPORTED_PROPERTY_TYPES
    def get_type(name)
      if has_key?(name)
        self[name]
      else
        raise "Unsupported property type: #{type}"
      end
    end
  end


  # Represents a quality measure definition
  class Measure
    
    attr_reader :id, :name, :steward, :properties, :parameters

    # Parses the supplied measure definition, extracts the measure properties
    # and calculates the values of any calculated dates. <tt>measure</tt> is 
    # expected to be a hash equivalent to that obtained from applying JSON.parse
    # to a JSON measure definition. The <tt>params</tt> hash should contain a
    # value for each parameter listed in the measure.
    def initialize(measure, params)
      @id = measure['id']
      @name = measure['name']
      @steward = measure['steward']
      @properties = {}
      measure['properties'].each do |property, value|
        @properties[property.intern] = Property.new(value['name'],
          value['type'], value['codes'])
      end
      @parameters = {}
      measure['parameters'].each do |parameter, value|
        if !params.has_key?(parameter.intern)
          raise "No value supplied for measure parameter: #{parameter}"
        end
        @parameters[parameter.intern] = Parameter.new(value['name'],
          value['type'], params[parameter.intern])
      end
      measure['calculated_dates'].each do |parameter, value|
        # calculate the value of each calculated date and add to the parameters
        # hash
        parser = Operator.new(@parameters)
        @parameters[parameter]=parser.parse(value)
      end
    end

  end

  # Represents a property of a quality measure
  class Property
    attr_reader :name, :type, :codes

    def initialize(name, type, codes)
      @name = name
      @type = SUPPORTED_PROPERTY_TYPES.get_type(type)
      @codes = codes
    end
  end

  # Represents a parameter of a quality measure
  class Parameter
    attr_reader :name, :type, :value

    def initialize(name, type, value)
      @name = name
      @type = SUPPORTED_PROPERTY_TYPES.get_type(type)
      @value = value
    end
  end

  class Operator
    def initialize(parameters)
      @parameters = parameters
    end

    def parse(expression)
      if expression.kind_of?(Hash)
        is_operator = expression.keys.any? do |key|
          key[0]=='$'
        end
        if is_operator && expression.size!=1
          throw 'Invalid expression, only operator allowed'
        end
        if is_operator
          operator = expression.keys[0]
          get_operator(operator, expression[operator])
        else
          TimePeriod.new(@parameters, expression)
        end
      elsif expression.kind_of?(String)
        if expression[0]=='@'
          TimePeriod.new(@parameters, {'val'=>@parameters[expression[1..-1]], 'unit'=>'second'})
        else
          TimePeriod.new(@parameters, {'val'=>expression, 'unit'=>'second'})
        end
      else
        throw "Unknown expression: #{expression}"
      end
    end

    def get_operator(operator, operands)
      if operator == '$minus'
        Minus.new(@parameters, operands)
      else
        throw "Unknown operator: #{operator}"
      end
    end
  end

  class Minus < Operator
    def initialize(parameters, operands)
      super(parameters)
      if (operands.size != 2)
        throw "Number of operands must be 2, #{operands.size} supplied"
      end
      @lh = parse(operands[0])
      @rh = parse(operands[1])
    end

    def evaluate
      return @lh.evaluate - @rh.evaluate
    end
  end

  class TimePeriod
    SECONDS_IN_A_YEAR = 365*24*60*60
    UNIT_FACTOR = {'year'=> SECONDS_IN_A_YEAR, 'month'=>SECONDS_IN_A_YEAR/12, 'day'=>24*60*60, 'second'=>1}
    def initialize(parameters, hash)
      super(parameters)
      @value = hash['val'].to_i
      @unit = hash['unit']
      if UNIT_FACTOR[@unit]==nil
        throw "Unknown unit: #{@unit}"
      end
    end

    def evaluate
      return @value * UNIT_FACTOR[@unit]
    end
  end
end
