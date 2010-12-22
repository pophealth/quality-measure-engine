module QME
  module Importer
    module Section
      # This module is used to import data from the Encounter section of a HITSP C32 document
      module MedicationImporter
        extend SectionBase
        
        # Extracts the dates of any medications that meet the code set defined for measure property.
        #
        # The following XPath expression is used to find the medications (substance administrations):
        #     //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.112']/cda:entry/cda:substanceAdministration
        #
        # Then the code is found using
        #     ./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code
        #
        # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
        #        will have the "cda" namespace registered to "urn:hl7-org:v3"
        # @param [Hash] property_description The description of a measure property pulled from the JSON
        #        measure definition
        # @return [Array] Provides an Array of dates for medications that have codes inside of the measure code set
        #         Dates will be represented as an Integer in seconds since the epoch
        def self.extract(doc, property_description)
          extract_date_list_based_on_section("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.112']/cda:entry/cda:substanceAdministration", 
                                             doc, property_description, "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code")
        end
      end
    end
  end
end