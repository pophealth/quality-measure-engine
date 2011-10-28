require "date"
require "date/delta"

module QME
  module Importer
    class ProviderImporter
      include Singleton
      
      # Extract Healthcare Providers from C32
      #
      # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
      #        will have the "cda" namespace registered to "urn:hl7-org:v3"
      # @return [Array] an array of providers found in the document
      def extract_providers(doc)
        
        performers = doc.xpath("//cda:documentationOf/cda:serviceEvent/cda:performer")
        
        providers = performers.map do |performer|
          provider = {}
          entity = performer.xpath(performer, "./cda:assignedEntity")
          name = entity.xpath("./cda:assignedPerson/cda:name")
          provider[:title]        = extract_data(name, "./cda:prefix")
          provider[:given_name]   = extract_data(name, "./cda:given")
          provider[:family_name]  = extract_data(name, "./cda:family")
          provider[:phone]        = extract_data(entity, "./cda:telecom/@value") { |text| text.gsub("tel:", "") }
          provider[:npi]          = extract_data(entity, "./cda:id[@root='2.16.840.1.113883.4.6']/@extension")
          provider[:organization] = extract_data(entity, "./cda:representedOrganization/cda:name")
          provider[:specialty]    = extract_data(entity, "./cda:code/@code")
          time                    = performer.xpath(performer, "./cda:time")
          provider[:start]        = extract_date(time, "./cda:low/@value")
          provider[:end]          = extract_date(time, "./cda:high/@value")
          provider
        end
      end
      
      private
      
      def extract_date(subject,query)
        date = extract_data(subject,query)
        date ? Date.parse(date).to_time.to_i : nil
      end
      
      # Returns nil if result is an empty string, block allows text munging of result if there is one
      def extract_data(subject, query)
        result = subject.xpath(query).text
        if result == ""
          nil
        elsif block_given?
          yield(result)
        else
          result
        end
      end
    end
  end
end