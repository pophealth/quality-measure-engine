module QME
  module Importer
    # Class that can be used to create an importer for a section of a HITSP C32 document. It usually
    # operates by selecting all CDA entries in a section and then checking to see if they match
    # a supplied code list
    class SectionImporter

      # Creates a new SectionImporter
      # @param [String] entry_xpath An XPath expression that can be used to find the desired entries
      # @param [String] code_xpath XPath expression to find the code element as a child of the desired CDA entry.
      #        Defaults to "./cda:code"
      def initialize(entry_xpath, code_xpath="./cda:code")
        @entry_xpath = entry_xpath
        @code_xpath = code_xpath
      end

      def extract(doc, property_description)
        if is_date_list_property?(property_description)
          extract_date_list_based_on_section(doc, property_description)
        elsif is_value_date_property?(property_description)
          extract_value_date_list_based_on_section(doc, property_description)
        end
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
      def extract_date_list_based_on_section(doc, property_description)
        basic_extractor(doc, property_description) do |entry_element, entry_list, date|
          entry_list << date if date
        end
      end
      
      # Extracts the dates and values of any CDA entries that meet the code set defined for measure property.
      #
      # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
      #        will have the "cda" namespace registered to "urn:hl7-org:v3"
      # @param [Hash] property_description The description of a measure property pulled from the JSON
      #        measure definition
      # @return [Array] Provides an Array of Hashes for entries that have codes inside of the measure code set
      #         Hashes will have a "value" and "date" property containing the respective data
      def extract_value_date_list_based_on_section(doc, property_description)
        basic_extractor(doc, property_description) do |entry_element, entry_list, date|
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
      
      def basic_extractor(doc, property_description)
        entry_list = []
        entry_elements = doc.xpath(@entry_xpath)
        entry_elements.each do |entry_element|
          date = extract_date_by_code(entry_element, property_description['codes'])
          yield entry_element, entry_list, date
        end
        
        entry_list
      end
      
      def extract_date_by_code(parent_element, code_list)
        date = nil

        code_elements = parent_element.xpath(@code_xpath)
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