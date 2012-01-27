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
      def extract_providers(doc, use_encounters=false)
        

        xpath_base = use_encounters ? "//cda:encounter/cda:performer" : "//cda:documentationOf/cda:serviceEvent/cda:performer"
  
        performers = doc.xpath(xpath_base)

        providers = performers.map do |performer|
          provider = {}
          entity = performer.xpath(performer, "./cda:assignedEntity")
          name = entity.xpath("./cda:assignedPerson/cda:name")
          provider[:title]        = extract_data(name, "./cda:prefix")
          provider[:given_name]   = extract_data(name, "./cda:given[1]")
          provider[:family_name]  = extract_data(name, "./cda:family")
          provider[:phone]        = extract_data(entity, "./cda:telecom/@value") { |text| text.gsub("tel:", "") }
          provider[:organization] = extract_data(entity, "./cda:representedOrganization/cda:name")
          provider[:specialty]    = extract_data(entity, "./cda:code/@code")
          time                    = performer.xpath(performer, "./cda:time")
          provider[:start]        = extract_date(time, "./cda:low/@value")
          provider[:end]          = extract_date(time, "./cda:high/@value")
          # NIST sample C32s use different OID for NPI vs C83, support both
          npi                     = extract_data(entity, "./cda:id[@root='2.16.840.1.113883.4.6' or @root='2.16.840.1.113883.3.72.5.2']/@extension")
          if ProviderImporter::valid_npi?(npi)
            provider[:npi]        = npi
          else
            puts "Warning: Invalid NPI (#{npi})"
          end
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
      
      # validate the NPI, should be 10 or 15 digits total with the final digit being a
      # checksum using the Luhn algorithm with additional special handling as described in
      # https://www.cms.gov/NationalProvIdentStand/Downloads/NPIcheckdigit.pdf 
      def self.valid_npi?(npi)
        return false if npi.length != 10 and npi.length != 15
        return false if npi.gsub(/\d/, '').length > 0 # npi must be all digits
        return false if npi.length == 15 and (npi =~ /^80840/)==nil # 15 digit npi must start with 80840
        
        # checksum is always calculated as if 80840 prefix is present
        if npi.length==10
          npi = '80840'+npi
        end
        
        return luhn_checksum(npi[0,14])==npi[14]
      end
      
      def self.luhn_checksum(num)
        double = {'0' => 0, '1' => 2, '2' => 4, '3' => 6, '4' => 8, '5' => 1, '6' => 3, '7' => 5, '8' => 7, '9' => 9}
        sum = 0
        num.reverse!
        num.split("").each_with_index do |char, i|
          if (i%2)==0
            sum+=double[char]
          else
            sum+=char.to_i
          end
        end
        sum = (9*sum)%10
        
        return sum.to_s
      end
    end
  end
end