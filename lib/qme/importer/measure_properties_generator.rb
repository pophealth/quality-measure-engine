module QME
  module Importer
    class MeasurePropertiesGenerator
      include Singleton
      
      def initialize
        @measure_importers = {}
      end
      
      # Adds a measure to run on a C32 that is passed in
      #
      # @param [MeasureBase] measure an Class that can extract information from a C32 that is necessary
      #        to calculate the measure
      def add_measure(measure_id, importer)
        @measure_importers[measure_id] = importer
      end
      
      
      def generate_properties(patient)
        measures = {}
        @measure_importers.each_pair do |measure_id, importer|
          measures[measure_id] = importer.parse(patient)
        end
        measures
      end
      
      def generate_properties!(patient)
        patient['measures'] = generate_properties(patient)
        patient.save!
      end
    end
  end
end