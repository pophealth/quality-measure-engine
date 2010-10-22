module QME

  # Represents a quality measure definition
  class Measure

    YEAR_IN_SECONDS = 365*24*60*60
    
    attr_reader :id, :name, :steward, :parameters

    # Parses the supplied measure definition, extracts the measure properties
    # and calculates the values of any calculated dates. <tt>measure</tt> is 
    # expected to be a hash equivalent to that obtained from applying JSON.parse
    # to a JSON measure definition. The <tt>params</tt> hash should contain a
    # value for each parameter listed in the measure.
    def initialize(measure, params)
      @id = measure['id']
      @name = measure['name']
      @steward = measure['steward']
      @parameters = {}
      measure['parameters'] ||= {}
      measure['parameters'].each do |parameter, value|
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
      measure['calculated_dates'] ||= {}
      measure['calculated_dates'].each do |parameter, value|
        @parameters[parameter.intern]=ctx.eval(value)
      end
    end

  end

end
