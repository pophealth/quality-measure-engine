module QME
  module Importer
    class MeasurePropertiesGenerator
      include Singleton
      
      def initialize
        @measure_importers = {}
      end
      
      # Adds a GenericImporter that will be used to extract
      # information about a measure from a patient Record.
      def add_measure(measure_id, importer)
        @measure_importers[measure_id] = importer
      end
      
      # Generates denormalized measure information
      # Measure information is contained in a Hash that hash
      # the measure id as a key, and the denormalized
      # measure information as a value
      #
      # @param [Record] patient - populated patient record
      # @returns Hash with denormalized measure information
      def generate_properties(patient)
        measures = {}
        @measure_importers.each_pair do |measure_id, importer|
          measures[measure_id] = importer.parse(patient)
        end
        measures
      end
      
      # The same as generate_properties but addes the denormalized
      # measure information into the Record and saves it.
      def generate_properties!(patient)
        patient['measures'] = generate_properties(patient)
        patient.save!
      end
    end
  end
end