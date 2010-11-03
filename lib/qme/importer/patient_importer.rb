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
        ns_context = Nokogiri::NamespaceContext.new(doc.root, {"cda"=>"urn:hl7-org:v3"})
        get_demographics(patient, ns_context)
      end
      
      def add_measure(measure)
        @measures << measure
      end
      
      # Inspects a C32 document and populates the patient Hash with first name, last name
      # birth date and gender.
      def get_demographics(patient, ns_context)
        patient['first'] = ns_context.first('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:given').text
        patient['last'] = ns_context.first('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:family').text
        birthdate_in_hl7ts_node = ns_context.first('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:birthTime')
        birthdate_in_hl7ts = birthdate_in_hl7ts_node['value']
        patient['birthdate'] = Time.gm(birthdate_in_hl7ts[0..3].to_i,
                                       birthdate_in_hl7ts[4..5].to_i,
                                       birthdate_in_hl7ts[6..7].to_i).to_i
        gender_node = ns_context.first('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:administrativeGenderCode')
        patient['gender'] = gender_node['code']
      end
    end
  end
end