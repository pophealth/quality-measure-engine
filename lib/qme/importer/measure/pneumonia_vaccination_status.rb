module QME
  module Importer
    module Measure
      # Extracts information relevant to calculating Pneumonia Vaccination Status for Older Adults (NQF 0043) from HITSP C32 documents
      # The following XPath expressions are used
      # 
      # Finding substanceAdministration elements in the Medications section 
      #     //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.112']/cda:entry/cda:substanceAdministration
      #
      # Finding coded medications within the substanceAdministration and searching for the pneumococcal vaccination
      #    ./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code
      #
      # Finding encounter elements in the Encounters section
      #    //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.127']/cda:entry/cda:encounter
      class PneumoniaVaccinationStatus
        def initialize(definition)
          @definition = definition
        end
        
        def parse(doc)
          measure_info = {}
          sa_elements = doc.xpath("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.112']/cda:entry/cda:substanceAdministration")
          sa_elements.each do |sa_element|
            code_elements = sa_element.xpath("./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code")
            code_elements.each do |code_element|
              if CodeSystemHelper.is_in_code_list?(code_element['codeSystem'], code_element['code'], 'vaccination', @definition)
                measure_info['vaccination'] = HL7Helper.timestamp_to_integer(sa_element.at_xpath('cda:effectiveTime')['value'])
              end
            end
          end
          
          encounter_elements = doc.xpath("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.127']/cda:entry/cda:encounter")
          encounter_elements.each do |encounter_element|
            code_element = encounter_element.at_xpath("./cda:code")
            if CodeSystemHelper.is_in_code_list?(code_element['codeSystem'], code_element['code'], 'encounter', @definition)
              measure_info['encounter'] = HL7Helper.timestamp_to_integer(encounter_element.at_xpath('cda:effectiveTime')['value'])
            end
          end
          
          measure_info
        end
      end
    end
  end
end