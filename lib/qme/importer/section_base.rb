module QME
  module Importer
    module SectionBase

      # Extracts the dates of any CDA entries that meet the code set defined for measure property.
      #
      # @param [String] xpath An XPath expression that can be used to find the desired entries
      # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
      #        will have the "cda" namespace registered to "urn:hl7-org:v3"
      # @param [Hash] property_description The description of a measure property pulled from the JSON
      #        measure definition
      # @param [String] code_xpath XPath expression to find the code element as a child of the desired CDA entry.
      #        Defaults to "./cda:code"
      # @return [Array] Provides an Array of dates for entries that have codes inside of the measure code set
      #         Dates will be represented as an Integer in seconds since the epoch
      def extract_date_list_based_on_section(xpath, doc, property_description, code_xpath="./cda:code")
        basic_extractor(xpath, doc, property_description, code_xpath) do |entry_element, entry_list, date|
          entry_list << date if date
        end
      end
      
      # Extracts the dates and values of any CDA entries that meet the code set defined for measure property.
      #
      # @param [String] xpath An XPath expression that can be used to find the desired entries
      # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
      #        will have the "cda" namespace registered to "urn:hl7-org:v3"
      # @param [Hash] property_description The description of a measure property pulled from the JSON
      #        measure definition
      # @param [String] code_xpath XPath expression to find the code element as a child of the desired CDA entry.
      #        Defaults to "./cda:code"
      # @return [Array] Provides an Array of Hashes for entries that have codes inside of the measure code set
      #         Hashes will have a "value" and "date" property containing the respective data
      def extract_value_date_list_based_on_section(xpath, doc, property_description, code_xpath="./cda:code")
        basic_extractor(xpath, doc, property_description, code_xpath) do |entry_element, entry_list, date|
          if date
            value = entry_element.at_xpath('cda:value')['value']
            entry_list << {'date' => date, 'value' => value}
          end
        end
      end

      # Determines if the property is a list of dates
      # @param [Hash] property_description The description of a measure property pulled from the JSON
      #        measure definition
      # @return [Boolean] true of false depending on the property
      def is_date_list_property?(property_description)
        property_description['type'] == 'array' && property_description['items']['type'] == 'number'
      end

      # Determines if the property is a list of date and value hashes
      # @param [Hash] property_description The description of a measure property pulled from the JSON
      #        measure definition
      # @return [Boolean] true of false depending on the property
      def is_value_date_property?(property_description)
        property_description['type'] == 'array' && property_description['items']['type'] == 'object' &&
        property_description['items']['properties']['value']['type'] == 'number' &&
        property_description['items']['properties']['date']['type'] == 'number'
      end
      
      private
      
      def basic_extractor(xpath, doc, property_description, code_xpath)
        entry_list = []
        entry_elements = doc.xpath(xpath)
        entry_elements.each do |entry_element|
          date = extract_date_by_code(entry_element, code_xpath, property_description['codes'])
          yield entry_element, entry_list, date
        end
        
        entry_list
      end
      
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
    end
  end
end