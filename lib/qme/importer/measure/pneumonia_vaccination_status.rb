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
      class PneumoniaVaccinationStatus < MeasureBase
        measure :id => '0043'
        
        def parse(doc)
          measure_info = {}
          sa_elements = doc.xpath("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.112']/cda:entry/cda:substanceAdministration")
          sa_elements.each do |sa_element|
            create_property_from_code(sa_element, "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code",
                                      'vaccination', measure_info)
          end
          
          encounter_elements(doc) do |encounter_element|
            create_property_from_code(encounter_element, "./cda:code", 'encounter', measure_info)
          end
          
          measure_info
        end
      end
    end
  end
end