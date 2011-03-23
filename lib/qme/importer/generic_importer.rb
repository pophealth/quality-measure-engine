module QME
  module Importer
    # Class that can be used to create a HITSP C32 importer for any quality measure. This class will construct
    # several SectionImporter for the various sections of the C32. When initialized with a JSON measure definition
    # it can then be passed a C32 document and will return a Hash with all of the information needed to calculate the measure.
    class GenericImporter

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
      def parse(patient_hash)
        measure_info = {}
        
        @definition['measure'].each_pair do |property, description|
          raise "No standard_category for #{property}" if !description['standard_category']
          matcher = PropertyMatcher.new(description)
          entry_list = symbols_for_property(description['standard_category'], description['qds_data_type']).map do |section|
            if patient_hash[section]
              patient_hash[section]
            else
              []
            end
          end.flatten
          if ! entry_list.empty?
            matched_list = matcher.match(entry_list)
            measure_info[property]=matched_list if matched_list.length>0
          end
        end
        
        measure_info
      end
      
      private
      
      def symbols_for_property(standard_category, qds_data_type)
        # Currently unsupported categories: negation_rationale, risk_category_assessment
        case standard_category
        when 'encounter'
          [:encounters]
        when 'procedure'
          case qds_data_type
          when 'procedure_performed'
            [:procedures]
          when 'procedure_adverse_event', 'procedure_intolerance'
            [:allergies]
          when 'procedure_result'
            [:procedures, :results, :vital_signs]
          end
        when 'risk_category_assessment'
          [:procedures]
        when 'communication'
          [:procedures]
        when 'laboratory_test'
          [:results, :vital_signs]
        when 'physical_exam'
          [:vital_signs]
        when 'medication'
          case qds_data_type
          when 'medication_dispensed', 'medication_order', 'medication_active', 'medication_administered'
            [:medications]
          when 'medication_allergy', 'medication_intolerance', 'medication_adverse_event'
            [:allergies]
          end
        when 'diagnosis_condition_problem'
          [:conditions, :social_history]
        when 'symptom'
          [:conditions, :social_history]
        when 'individual_characteristic'
          [:conditions, :social_history]
        when 'device'
          case qds_data_type
          when 'device_applied'
            [:conditions, :procedures, :care_goals, :medical_equipment]
          when 'device_allergy'
            [:allergies]
          end
        when 'care_goal'
          [:care_goals]
        when 'diagnostic_study'
          [:procedures]
        when 'substance'
          [:allergies]
        else
          unless @warnings.include?(standard_category)
            puts "Warning: Unsupported standard_category (#{standard_category})"
          end
          []
        end
      end
    end
  end
end