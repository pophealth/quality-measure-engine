module QME
  module Importer

    # A base class for all measure HITSP C32 measure importers
    class MeasureBase

      # Creates a measure importer with the definition passed in
      #
      # @param [Hash] definition the parsed representation of the measure definition
      def initialize(definition)
        @definition = definition
      end
      
      
    end
  end
end