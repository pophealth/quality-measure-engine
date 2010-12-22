module QME
  module Importer
    module Section
      # This module is used to import data from the Condition section of a HITSP C32 document
      module ConditionImporter
        extend SectionBase
        
        # Extracts the dates of any conditions that meet the code set defined for measure property.
        #
        # The following XPath expression is used to find the encounters:
        #     //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.103']/cda:entry/cda:act/cda:entryRelationship/cda:observation
        #
        # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
        #        will have the "cda" namespace registered to "urn:hl7-org:v3"
        # @param [Hash] property_description The description of a measure property pulled from the JSON
        #        measure definition
        # @return [Array] Provides an Array of dates for conditions that have codes inside of the measure code set
        #         Dates will be represented as an Integer in seconds since the epoch
        def self.extract(doc, property_description)
          extract_date_list_based_on_section("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.103']/cda:entry/cda:act/cda:entryRelationship/cda:observation", 
                                             doc, property_description, "./cda:value")
        end
      end
    end
  end
end