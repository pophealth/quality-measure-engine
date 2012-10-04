module QME
  module Importer
    module EntryFilter
      class << self
        attr_accessor :warnings
      end

      @warnings = []

      def filter_entries(standard_category, qds_data_type, patient)
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

      def filter_entries_by_codes(entry_list, codes)
        matching_values = []
        entry_list.each do |entry|
          if entry.usable?
            if entry.is_in_code_set?(codes)
              yield entry, matching_values
            end
          end
        end
        
        matching_values
      end
    end
  end
end