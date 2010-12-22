module QME
  module Importer
    module Section
      # This module is used to import data observations from a HITSP C32 document
      module VitalSignImporter
        extend SectionBase
        
        # Extracts the dates of any vital sign observations that meet the code set defined for measure property.
        #
        # For finding result observations 
        #    //cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.14']
        #
        # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
        #        will have the "cda" namespace registered to "urn:hl7-org:v3"
        # @param [Hash] property_description The description of a measure property pulled from the JSON
        #        measure definition
        # @return [Array] Provides an Array of dates for vital signs that have codes inside of the measure code set
        #         Dates will be represented as an Integer in seconds since the epoch
        def self.extract(doc, property_description)
          if is_date_list_property?(property_description)
            extract_date_list_based_on_section("//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.14']", 
                                               doc, property_description)
          elsif is_value_date_property?(property_description)
            extract_value_date_list_based_on_section("//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.14']", 
                                                     doc, property_description)
          end
        end
      end
    end
  end
end