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
          entry_list = symbols_for_category(description['standard_category']).flat_map do |section|
            if patient_hash[section]
              patient_hash[section]
            else
              []
            end
          end
          if ! entry_list.empty?
            matched_list = matcher.match(entry_list)
            measure_info[property]=matched_list if matched_list.length>0
          end
        end
        
        measure_info
      end
      
      private
      
      def symbols_for_category(standard_category)
        # Currently unsupported categories:
        # characteristic, substance_allergy, medication_allergy, negation_rationale,
        # diagnostic_study
        case standard_category
        when 'encounter'; [:encounters]
        when 'procedure'; [:procedures]
        when 'communication'; [:procedures]
        when 'laboratory_test'; [:results, :vital_signs]
        when 'physical_exam'; [:vital_signs]
        when 'medication'; [:medications]
        when 'diagnosis_condition_problem'; [:conditions, :social_history]
        when 'device'; [:conditions, :procedures, :care_goals, :medical_equipment]
        when 'care_goal'; [:care_goals]
        when 'diagnostic_study'; [:procedures]
        else
          if !@@warnings[standard_category]
            puts "Warning: Unsupported standard_category (#{standard_category})"
            @@warnings[standard_category]=true
          end
          []
        end
      end
    end
  end
end