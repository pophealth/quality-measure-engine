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

      # Traverses that HITSP C32 document passed in using XPath and pulls out the values needed to
      # calculate a quality measure
      # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
      #        will have the "cda" namespace registered to "urn:hl7-org:v3"
      # @param [Hash] property_description The description of a measure property pulled from the JSON
      #        measure definition
      # @return [Hash] Keys of the hash will be names of the properties for a given quality measure.
      #         Values will be the values (usually dates) extracted from the C32
      def extract(doc, property_description)
        if is_date_list_property?(property_description)
          extract_date_list_based_on_section(doc, property_description)
        elsif is_value_date_property?(property_description)
          extract_value_date_list_based_on_section(doc, property_description)
        elsif is_date_range_property?(property_description)
          extract_date_range_list_based_on_section(doc, property_description)
        else
          raise "Unknown property schema for property #{property_description['description']}"
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
          if date && entry_element.at_xpath('cda:value')
            value = entry_element.at_xpath('cda:value')['value']
            entry_list << {'date' => date, 'value' => value}
          end
        end
      end
      
      # Extracts the date ranges of any CDA entries that meet the code set defined for measure property.
      #
      # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
      #        will have the "cda" namespace registered to "urn:hl7-org:v3"
      # @param [Hash] property_description The description of a measure property pulled from the JSON
      #        measure definition
      # @return [Array] Provides an Array of Hashes for entries that have codes inside of the measure code set
      #         Hashes will have a "start" and "end" property containing the respective data
      def extract_date_range_list_based_on_section(doc, property_description)
        basic_extractor(doc, property_description) do |entry_element, entry_list, date|
          if date && entry_element.at_xpath('cda:effectiveTime/cda:high')
            end_date = HL7Helper.timestamp_to_integer(entry_element.at_xpath('cda:effectiveTime/cda:high')['value'])
            entry_list << {'start' => date, 'end' => end_date}
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
        property_description['items']['properties']['value'] &&
        property_description['items']['properties']['date']
      end
      
      # Determines if the property is a list of date ranges represented by a Hash with start and end
      # krys
      # @param [Hash] property_description The description of a measure property pulled from the JSON
      #        measure definition
      # @return [Boolean] true of false depending on the property
      def is_date_range_property?(property_description)
        property_description['type'] == 'array' && property_description['items']['type'] == 'object' &&
        property_description['items']['properties']['start'] &&
        property_description['items']['properties']['end']
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