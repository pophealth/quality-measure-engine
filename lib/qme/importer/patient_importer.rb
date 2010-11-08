module QME
  module Importer
    class PatientImporter
      include Singleton
      
      def initialize
        @measures = []
      end
      
      # Parses a HITSP C32 document and returns a Hash of of the patient.
      def parse_c32(doc)
        patient = {}
        get_demographics(patient, doc)
      end
      
      def add_measure(measure)
        @measures << measure
      end
      
      # Inspects a C32 document and populates the patient Hash with first name, last name
      # birth date and gender.
      def get_demographics(patient, doc)
        patient['first'] = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:given').text
        patient['last'] = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:family').text
        birthdate_in_hl7ts_node = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:birthTime')
        birthdate_in_hl7ts = birthdate_in_hl7ts_node['value']
        patient['birthdate'] = HL7Helper.timestamp_to_integer(birthdate_in_hl7ts)
        gender_node = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:administrativeGenderCode')
        patient['gender'] = gender_node['code']
      end
    end
  end
end