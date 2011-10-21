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
        performers = doc.xpath("//cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity")
        
        providers = performers.map do |performer|
          provider = {}
          name = performer.xpath("./cda:assignedPerson/cda:name")
          provider[:title]        = extract_data(name, "./cda:prefix")
          provider[:given_name]   = extract_data(name, "./cda:given")
          provider[:family_name]  = extract_data(name, "./cda:family")
          provider[:phone]        = extract_data(performer, "./cda:telecom/@value") { |text| text.gsub("tel:", "") }
          provider[:npi]          = extract_data(performer, "./cda:id[@root='2.16.840.1.113883.4.6']/@extension")
          provider[:organization] = extract_data(performer, "./cda:representedOrganization/cda:name")
          provider[:specialty]    = extract_data(performer, "./cda:code/@code")
          provider
        end
      end
      
      private
      
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