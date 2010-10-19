module Engine

  SUPPORTED_PROPERTY_TYPES = {'long'=>:long, 'boolean'=>:boolean}


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
      measure["properties"].each do |property, value|
        @properties[property.intern] = Property.new(value['name'],
          value['type'], value['codes'])
      end
      @parameters = {}
      measure["parameters"].each do |parameter, value|
        if !params.has_key?(parameter.intern)
          raise "No value supplied for measure parameter: #{parameter}"
        end
        @parameters[parameter.intern] = Parameter.new(value['name'], value['type'], params[parameter.intern])
      end
    end

  end

  # Represents a property of a quality measure
  class Property
    attr_reader :name, :type, :codes

    def initialize(name, type, codes)
      @name = name
      if SUPPORTED_PROPERTY_TYPES.has_key?(type)
        @type = SUPPORTED_PROPERTY_TYPES[type]
      else
        raise "Unsupported property type: #{type}"
      end
      @codes = codes
    end
  end

  # Represents a parameter of a quality measure
  class Parameter
    attr_reader :name, :type, :value

    def initialize(name, type, value)
      @name = name
      if SUPPORTED_PROPERTY_TYPES.has_key?(type)
        @type = SUPPORTED_PROPERTY_TYPES[type]
      else
        raise "Unsupported parameter type: #{type}"
      end
      @value = value
    end
  end
end
