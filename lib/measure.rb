require 'v8'

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

    YEAR_IN_SECONDS = 365
    
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
      ctx = V8::Context.new
      ctx['year']=365*24*60*60
      @parameters.each do |key, param|
        ctx[key]=param.value
      end
      measure['calculated_dates'].each do |parameter, value|
        @parameters[parameter.intern]=Parameter.new(parameter, 'long', ctx.eval(value))
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

end
