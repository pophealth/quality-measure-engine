module QME
  module Importer
    # Class that can be used to create a HITSP C32 importer for any quality measure. This class will construct
    # several SectionImporter for the various sections of the C32. When initialized with a JSON measure definition
    # it can then be passed a C32 document and will return a Hash with all of the information needed to calculate the measure.
    class GenericImporter
      include EntryFilter

      # Creates a generic importer for any quality measure.
      #
      # @param [Hash] definition A measure definition described in JSON
      def initialize(definition)
        @definition = definition
        @warnings = []
      end

      # Parses a HITSP C32 document and returns a Hash of information related to the measure
      #
      # @param [Hash] patient_hash representation of a patient
      # @return [Hash] measure information
      def parse(patient)
        measure_info = {}
        @definition['measure'].each_pair do |property, description|
          raise "No standard_category for #{property}" if !description['standard_category']
          matcher = PropertyMatcher.new(description)
          entry_list = filter_entries(description['standard_category'], description['qds_data_type'], patient)
          if ! entry_list.empty?
            matched_list = matcher.match(entry_list)
            measure_info[property] = matched_list if matched_list.length > 0
          end
        end
        measure_info
      end
    end
  end
end