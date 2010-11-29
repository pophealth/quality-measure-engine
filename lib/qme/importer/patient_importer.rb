module QME
  module Importer
    
    # This class is the central location for taking a HITSP C32 XML document and converting it
    # into the processed form we store in MongoDB. The class does this by running each measure
    # independently on the XML document
    #
    # This class is a Singleton. It should be accessed by calling PatientImporter.instance
    class PatientImporter
      include Singleton
      
      def initialize
        @measures = []
      end
      
      # Parses a HITSP C32 document and returns a Hash of of the patient.
      #
      # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
      #        will have the "cda" namespace registered to "urn:hl7-org:v3"
      # @return [Hash] a represnetation of the patient that can be inserted into MongoDB
      def parse_c32(doc)
        patient = {}
        get_demographics(patient, doc)
        patient['measures'] = {}
        @measures.each do |measure|
          measure.extract_measure_properties(patient, doc)
        end
        
        patient
      end
      
      # Adds a measure to run on a C32 that is passed in
      #
      # @param [MeasureBase] measure an instance of a measure you want to run on any C32 that is passed in to the importer
      def add_measure(measure)
        @measures << measure
      end
      
      # Inspects a C32 document and populates the patient Hash with first name, last name
      # birth date and gender.
      #
      # @param [Hash] patient A hash that is used to represent the patient
      # @param [Nokogiri::XML::Node] doc The C32 document parsed by Nokogiri
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