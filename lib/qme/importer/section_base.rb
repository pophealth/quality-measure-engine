module QME
  module Importer
    module SectionBase
      def extract_date_by_code(parent_element, xpath_expression, code_list)
        date = nil

        code_elements = parent_element.xpath(xpath_expression)
        code_elements.each do |code_element|
          if CodeSystemHelper.is_in_codes?(code_element['codeSystem'], code_element['code'], code_list)
            if parent_element.at_xpath('cda:effectiveTime')['value']
              date = HL7Helper.timestamp_to_integer(parent_element.at_xpath('cda:effectiveTime')['value'])
            elsif parent_element.at_xpath('cda:effectiveTime/cda:low')['value']
              date = HL7Helper.timestamp_to_integer(parent_element.at_xpath('cda:effectiveTime/cda:low')['value'])
            end

          end
        end

        date
      end
      
      # Extracts the dates of any CDA entries that meet the code set defined for measure property.
      #
      # @param [String] xpath An XPath expression that can be used to find the desired entries
      # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
      #        will have the "cda" namespace registered to "urn:hl7-org:v3"
      # @param [Hash] property_description The description of a measure property pulled from the JSON
      #        measure definition
      # @return [Array] Provides an Array of dates for entries that have codes inside of the measure code set
      #         Dates will be represented as an Integer in seconds since the epoch
      def extract_date_list_based_on_section(xpath, doc, property_description)
        entry_list = []
        entry_elements = doc.xpath(xpath)
        entry_elements.each do |entry_element|
          date = extract_date_by_code(entry_element, "./cda:code", property_description['codes'])
          entry_list << date if date
        end
        
        entry_list
      end
    end
  end
end