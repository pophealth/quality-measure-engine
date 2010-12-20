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
        @measure_classes = []
      end
      
      # Will create instances of the importers based on the added Measures. It will look in the
      # measures and figure out their id's and sub id's by calling methods on their classes
      # It will then look for the definitions of these measures in the "measures" collection
      # of the database passed in.
      def initialize_measures(db)
        @measure_classes.each do |mc|
          definition = nil
          if mc.measure_sub_id
            definition = db['measures'].find_one(:id => mc.measure_id)
          else
            definition = db['measures'].find_one(:id => mc.measure_id, :sub_id => mc.measure_sub_id)
          end
          
          @measures << mc.new(definition)
        end
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
      # @param [MeasureBase] measure an Class that can extract information from a C32 that is necessary
      #        to calculate the measure
      def add_measure(measure)
        @measure_classes << measure
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