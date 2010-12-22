module QME
  module Importer
    module Section
      # This module is used to import data observations from a HITSP C32 document
      module ResultImporter
        extend SectionBase
        
        # Extracts the dates of any result observations that meet the code set defined for measure property.
        #
        # For finding result observations 
        #    //cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.15']
        #
        # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
        #        will have the "cda" namespace registered to "urn:hl7-org:v3"
        # @param [Hash] property_description The description of a measure property pulled from the JSON
        #        measure definition
        # @return [Array] Provides an Array of dates for procedures that have codes inside of the measure code set
        #         Dates will be represented as an Integer in seconds since the epoch
        def self.extract(doc, property_description)
          extract_date_list_based_on_section("//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.15']", 
                                             doc, property_description)
        end
      end
    end
  end
end