module QME
  module Importer
    # Class that can be used to create a HITSP C32 importer for any quality measure. This class will construct
    # several SectionImporter for the various sections of the C32. When initialized with a JSON measure definition
    # it can then be passed a C32 document and will return a Hash with all of the information needed to calculate the measure.
    class GenericImporter

      @@warnings = {}

      # Creates a generic importer for any quality measure.
      #
      # @param [Hash] definition A measure definition described in JSON
      def initialize(definition)
        @definition = definition
      end
      
      # Parses a HITSP C32 document and returns a Hash of information related to the measure
      #
      # @param [Hash] patient_hash representation of a patient
      # @return [Hash] measure information
      def parse(patient_hash)
        measure_info = {}
        
        @definition['measure'].each_pair do |property, description|
          raise "No standard_category for #{property}" if !description['standard_category']
          matcher = PropertyMatcher.new(description)
          entry_list = patient_hash[symbol_for_category(description['standard_category'])]
          if entry_list
            matched_list = matcher.match(entry_list)
            if matched_list && matched_list.length>0
              measure_info[property] = matched_list
            end
          end
        end
        
        measure_info
      end
      
      private
      
      def symbol_for_category(standard_category)
        # Currently unsupported categories:
        # characteristic, substance_allergy, medication_allergy, negation_rationale,
        # care_goal, diagnostic_study, device, communication
        case standard_category
        when 'encounter'; :encounters
        when 'procedure'; :procedures
        when 'laboratory_test'; :results
        when 'physical_exam'; :vital_signs
        when 'medication'; :medications
        when 'diagnosis_condition_problem'; :conditions
        else
          if !@@warnings[standard_category]
            puts "Warning: Unsupported standard_category (#{standard_category})"
            @@warnings[standard_category]=true
          end
          nil
        end
      end
    end
  end
end