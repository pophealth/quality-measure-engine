module QME
  module Importer
    # Class that can be used to create a HITSP C32 importer for any quality measure. This class will construct
    # several SectionImporter for the various sections of the C32. When initialized with a JSON measure definition
    # it can then be passed a C32 document and will return a Hash with all of the information needed to calculate the measure.
    class GenericImporter
      
      # Creates a generic importer for any quality measure. The following XPath expressions are used to
      # find information in a HITSP C32 document:
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
      # Codes for conditions are determined by examining the value child element as opposed to the code child element
      #
      # @param [Hash] definition A measure definition described in JSON
      def initialize(definition)
        @definition = definition
        
        @encounter_importer = SectionImporter.new("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.127']/cda:entry/cda:encounter")
        @procedure_importer = SectionImporter.new("//cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.1.29']")
        @result_importer = SectionImporter.new("//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.15']")
        @vital_sign_importer = SectionImporter.new("//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.14']")
        @medication_importer = SectionImporter.new("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.112']/cda:entry/cda:substanceAdministration",
                                                   "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code")

        @condition_importer = SectionImporter.new("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.103']/cda:entry/cda:act/cda:entryRelationship/cda:observation",
                                                  "./cda:value")
      end
      
      # Parses a HITSP C32 document and returns a Hash of information related to the measure
      #
      # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
      #        will have the "cda" namespace registered to "urn:hl7-org:v3"
      # @return [Hash] measure information
      def parse(doc)
        measure_info = {}
        
        @definition['measure'].each_pair do |property, description|
          raise "No standard_category for #{property}" if !description['standard_category']
          importer = importer_for_category(description['standard_category'])
          measure_info[property] = importer.extract(doc, description)
        end
        
        measure_info
      end
      
      private
      
      def importer_for_category(standard_category)
        # Currently unsupported categories:
        # characteristic, substance_allergy, medication_allergy, negation_rationale,
        # care_goal
        case standard_category
        when 'encounter'; @encounter_importer
        when 'procedure'; @procedure_importer
        when 'laboratory_test';@result_importer
        when 'physical_exam'; @vital_sign_importer
        when 'medication'; @medication_importer
        when 'diagnosis_condition_problem'; @condition_importer
        else raise "No importer for catgeory #{standard_category}"
        end
      end
    end
  end
end