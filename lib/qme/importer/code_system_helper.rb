module QME
  module Importer
    
    # General helpers for working with codes and code systems
    class CodeSystemHelper
      CODE_SYSTEMS = {
        '2.16.840.1.113883.6.1' => 'LOINC',
        '2.16.840.1.113883.6.96' => 'SNOMED-CT',
        '2.16.840.1.113883.6.12' => 'CPT',
        '2.16.840.1.113883.6.88' => 'RxNorm'
      }
      
      # Returns the name of a code system given an oid
      # @param [String] oid of a code system
      # @return [String] the name of the code system as described in the measure definition JSON
      def self.code_system_for(oid)
        CODE_SYSTEMS[oid]
      end
      
      # Checks if a code is in the list of possible codes for a particular property in a
      # measure definition
      # @param [String] code_system_oid the oid of the code system used
      # @param [String] code to check
      # @param [String] property_name name of the property to match in the JSON definition
      # @param [Hash] measure_definition the measure definition JSON
      # @return [true, false] whether the code is in the list of desired codes
      def self.is_in_code_list?(code_system_oid, code, property_name, measure_definition)
        code_system_name = code_system_for(code_system_oid)
        code_lists = measure_definition['properties'][property_name]['codes']
        codes_for_system = code_lists.find {|cs| cs['set'] == code_system_name}
        if codes_for_system
          if codes_for_system['values'].include?(code)
            return true
          end
        end
        
        false
      end
    end
  end
end