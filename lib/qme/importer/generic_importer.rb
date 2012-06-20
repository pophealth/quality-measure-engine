module QME
  module Importer
    # Class that can be used to create a HITSP C32 importer for any quality measure. This class will construct
    # several SectionImporter for the various sections of the C32. When initialized with a JSON measure definition
    # it can then be passed a C32 document and will return a Hash with all of the information needed to calculate the measure.
    class GenericImporter

      class << self
        attr_accessor :warnings
      end

      @warnings = []

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
          entry_list = filter_for_property(description['standard_category'], description['qds_data_type'], patient)
          if ! entry_list.empty?
            matched_list = matcher.match(entry_list)
            measure_info[property] = matched_list if matched_list.length > 0
          end
        end
        measure_info
      end

      private

      def filter_for_property(standard_category, qds_data_type, patient)
        # Currently unsupported categories: negation_rationale, risk_category_assessment
        case standard_category
        when 'encounter'
          patient.encounters
        when 'immunization'
          patient.immunizations
        when 'procedure'
          case qds_data_type
          when 'procedure_performed'
            patient.procedures_performed
          when 'procedure_adverse_event', 'procedure_intolerance'
            patient.allergies
          when 'procedure_result'
            patient.procedure_results
          end
        when 'risk_category_assessment'
          patient.procedures
        when 'communication'
          patient.procedures
        when 'laboratory_test'
          patient.laboratory_tests
        when 'physical_exam'
          patient.procedure_results
        when 'medication'
          case qds_data_type
          when 'medication_dispensed', 'medication_order', 'medication_active', 'medication_administered'
            patient.all_meds
          when 'medication_allergy', 'medication_intolerance', 'medication_adverse_event'
            patient.allergies
          end
        when 'diagnosis_condition_problem'
          case qds_data_type
          when 'diagnosis_active'
            patient.active_diagnosis
          when 'diagnosis_active_priority_principal'
            patient.active_diagnosis
          when 'diagnosis_inactive'
            patient.inactive_diagnosis
          when 'diagnosis_resolved'
            patient.resolved_diagnosis
          end
        when 'symptom'
          patient.all_problems
        when 'individual_characteristic'
          patient.all_problems
        when 'device'
          case qds_data_type
            when 'device_applied'
             patient.all_devices
            when 'device_allergy'
              patient.allergies
          end
        when 'care_goal'
          patient.care_goals
        when 'diagnostic_study'
          case qds_data_type
           
             when 'diagnostic_study_performed'
               patient.procedures
             when 'diagnostic_study_result'
              patient.procedure_results
            end
        when 'substance'
          patient.allergies
        else
          unless self.class.warnings.include?(standard_category)
            puts "Warning: Unsupported standard_category (#{standard_category})"
            self.class.warnings << standard_category
          end
          []
        end
      end
    end
  end
end