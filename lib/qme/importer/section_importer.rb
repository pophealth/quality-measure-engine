module QME
  module Importer
    # Class that can be used to create an importer for a section of a HITSP C32 document. It usually
    # operates by selecting all CDA entries in a section and then creates entries for them.
    class SectionImporter
          attr_accessor :check_for_usable
      # Creates a new SectionImporter
      # @param [String] entry_xpath An XPath expression that can be used to find the desired entries
      # @param [String] code_xpath XPath expression to find the code element as a child of the desired CDA entry.
      #        Defaults to "./cda:code"
      # @param [String] status_xpath XPath expression to find the status element as a child of the desired CDA
      #        entry. Defaults to nil. If not provided, a status will not be checked for since it is not applicable
      #        to all enrty types
      def initialize(entry_xpath, code_xpath="./cda:code", status_xpath=nil, description_xpath="./cda:code/cda:originalText/cda:reference[@value] | ./cda:text/cda:reference[@value] ")
        @entry_xpath = entry_xpath
        @code_xpath = code_xpath
        @status_xpath = status_xpath
        @description_xpath = description_xpath
        @check_for_usable = true               # Pilot tools will set this to false
      end


      # Traverses that HITSP C32 document passed in using XPath and creates an Array of Entry
      # objects based on what it finds                          
      # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
      #        will have the "cda" namespace registered to "urn:hl7-org:v3"
      #        measure definition
      # @return [Array] will be a list of Entry objects
      def create_entries(doc)
        entry_list = []
        entry_elements = doc.xpath(@entry_xpath)
        entry_elements.each do |entry_element|
          entry = Entry.new
          extract_codes(entry_element, entry)
          extract_dates(entry_element, entry)
         extract_value(entry_element, entry)
          if @status_xpath
            extract_status(entry_element, entry)
          end
          if @description_xpath
            extract_description(entry_element, entry)
          end
          if !@check_for_usable or entry.usable?   # if we want all entries, or we want only usable entries, and the entry is usable
            entry_list << entry
          end
        end
        entry_list
      end

      private

      def extract_status(parent_element, entry)
        status_element = parent_element.at_xpath(@status_xpath)
        if status_element
          case status_element['code']
          when '55561003'
            entry.status = :active
          when '73425007'
            entry.status = :inactive
          when '413322009'      
            entry.status = :resolved
          end
        end
      end

      def extract_description(parent_element, entry)
#       STDERR.puts "***extract_description #{parent_element} \n\t*entry #{entry}  \n\t*description_xpath = #{@description_xpath}"
        code_elements = parent_element.xpath(@description_xpath)
#        STDERR.puts "Found #{code_elements.size} elements"
        code_elements.each do |code_element|
#                STDERR.puts "\tcode_element = #{code_element}"
                  tag = code_element['value']
                  value = "NOT FOUND - #{tag}"
                  # This seems a bit aggressive, but it works.   The ID can be cound in all sorts of tags.
                 path = "//*[@ID='#{tag}']"
               # Not sure why, but sometimes the reference is #<Reference> and the ID value is <Reference>, and 
               # sometimes it is #<Reference>.  We look for both.
                  if code_element.document.xpath(path)[0]
                        value = code_element.document.xpath(path)[0].content
                  else 
                      if tag[0] == '#'
                        tag = tag[1,tag.length]
                        # This seems a bit aggressive, but it works.   The ID can be cound in all sorts of tags.
                        path = "//*[@ID='#{tag}']"
                        if code_element.document.xpath(path)[0]
                                value = code_element.document.xpath(path)[0].content
                        end
                      end       
                   end
#                  STDERR.puts "Reference = #{code_element['value']}  tag = #{tag} has value #{value}"
                  entry.description = value
        end
      end
      def extract_codes(parent_element, entry)
        code_elements = parent_element.xpath(@code_xpath)
        code_elements.each do |code_element|
          add_code_if_present(code_element, entry)
          translations = code_element.xpath('cda:translation')
          translations.each do |translation|
            add_code_if_present(translation, entry)
          end
        end
      end

      def add_code_if_present(code_element, entry)
        if code_element['codeSystem'] && code_element['code']
          entry.add_code(code_element['code'], CodeSystemHelper.code_system_for(code_element['codeSystem']))
        end
      end

      def extract_dates(parent_element, entry)
        if parent_element.at_xpath('cda:effectiveTime')
          entry.time = HL7Helper.timestamp_to_integer(parent_element.at_xpath('cda:effectiveTime')['value'])
        end
        if parent_element.at_xpath('cda:effectiveTime/cda:low')
          entry.start_time = HL7Helper.timestamp_to_integer(parent_element.at_xpath('cda:effectiveTime/cda:low')['value'])
        end
        if parent_element.at_xpath('cda:effectiveTime/cda:high')
          entry.end_time = HL7Helper.timestamp_to_integer(parent_element.at_xpath('cda:effectiveTime/cda:high')['value'])
        end
        if parent_element.at_xpath('cda:effectiveTime/cda:center')
          entry.time = HL7Helper.timestamp_to_integer(parent_element.at_xpath('cda:effectiveTime/cda:center')['value'])
        end
      end

      def extract_value(parent_element, entry)
        value_element = parent_element.at_xpath('cda:value')
        if value_element
          value = value_element['value']
          unit = value_element['unit']
          if value
            entry.set_value(value, unit)
          end
        end
      end
    end
  end
end

if __FILE__ == $0
 
 require 'nokogiri'
 require_relative 'entry'
 require_relative 'code_system_helper'
 require_relative 'hl7_helper'


# procedures
        si = QME::Importer::SectionImporter.new("//cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.1.29']",
                                                  "./cda:code", nil,
                                                "./cda:code/cda:originalText/cda:reference[@value]")
    si.check_for_usable = false
    doc = Nokogiri::XML(File.new('/home/saul/src/pilot-toolkit/play.XML'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

    entries = si.create_entries(doc)
    STDERR.puts entries.size


end
