require 'erb'
require 'ostruct'

module QME
  module Randomizer
  
    # Provides functionality for randomizing patient records based on erb templates
    class Patient

      # Utility class used to supply a binding to Erb
      class Context < OpenStruct
        # Create a new context
        # @param [Hash] vars a hash of parameter names (String) and values (Object). Each entry is added as an accessor of the new Context
        def initialize(vars)
          super(vars)
        end
      
        # Get a binding that for the current instance
        # @return [Binding]
        def get_binding
          binding
        end
      end

      # Create a new instance with the supplied template
      # @param [String] patient the patient template
      def initialize(patient)
        @template = ERB.new(patient)
      end
      
      # Get a randomized record based on the stored template
      # @return [String] a randomized patient
      def get
        context = Context.new({})
        @template.result(context.get_binding)
      end

    end
  end
end