module QME
  module Importer
    
    # This class is the central location for taking a HITSP C32 XML document and converting it
    # into the processed form we store in MongoDB. The class does this by running each measure
    # independently on the XML document
    #
    # This class is a Singleton. It should be accessed by calling PatientImporter.instance
    class PatientImporter
      include Singleton
      
      # Creates a new PatientImporter with the following XPath expressions used to find content in 
      # a HITSP C32:
      #
      # Encounter entries
      #    //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.127']/cda:entry/cda:encounter
      #
      # Procedure entries
      #    //cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.1.29']
      #
      # Result entries
      #    //cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.15']
      #
      # Vital sign entries
      #    //cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.14']
      #
      # Medication entries
      #    //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.112']/cda:entry/cda:substanceAdministration
      #
      # Codes for medications are found in the substanceAdministration with the following relative XPath
      #    ./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code
      #
      # Condition entries
      #    //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.103']/cda:entry/cda:act/cda:entryRelationship/cda:observation
      #
      # Social History entries (non-C32 section, specified in the HL7 CCD)
      #    //cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.19']
      #
      # Care Goal entries(non-C32 section, specified in the HL7 CCD)
      #    //cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.1.25']
      #
      # Codes for conditions are determined by examining the value child element as opposed to the code child element
      def initialize
        @measure_importers = {}
        
        @section_importers = {}
        @section_importers[:encounters] = SectionImporter.new("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.127']/cda:entry/cda:encounter")
        @section_importers[:procedures] = SectionImporter.new("//cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.1.29']")
        @section_importers[:results] = SectionImporter.new("//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.15']")
        @section_importers[:vital_signs] = SectionImporter.new("//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.14']")
        @section_importers[:medications] = SectionImporter.new("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.112']/cda:entry/cda:substanceAdministration",
                                                               "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code")

        @section_importers[:conditions] = SectionImporter.new("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.103']/cda:entry/cda:act/cda:entryRelationship/cda:observation",
                                                              "./cda:value")
                                                              
        @section_importers[:social_history] = SectionImporter.new("//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.19']")
        @section_importers[:care_goals] = SectionImporter.new("//cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.1.25']")
      end
            
      # Parses a HITSP C32 document and returns a Hash of of the patient.
      #
      # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
      #        will have the "cda" namespace registered to "urn:hl7-org:v3"
      # @return [Hash] a represnetation of the patient that can be inserted into MongoDB
      def parse_c32(doc)
        patient_record = {}
        c32_patient = create_c32_hash(doc)
        get_demographics(patient_record, doc)
        patient_record['measures'] = {}
        @measure_importers.each_pair do |measure_id, importer|
          patient_record['measures'][measure_id] = importer.parse(doc, c32_patient)
        end
        
        patient_record
      end
      
      # Adds a measure to run on a C32 that is passed in
      #
      # @param [MeasureBase] measure an Class that can extract information from a C32 that is necessary
      #        to calculate the measure
      def add_measure(measure_id, importer)
        @measure_importers[measure_id] = importer
      end
      
      # Create a simple representation of the patient from a HITSP C32
      #
      # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
      #        will have the "cda" namespace registered to "urn:hl7-org:v3"
      # @return [Hash] a represnetation of the patient with symbols as keys for each section
      def create_c32_hash(doc)
        c32_patient = {}
        @section_importers.each_pair do |section, importer|
          c32_patient[section] = importer.create_entries(doc)
        end
        
        c32_patient
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