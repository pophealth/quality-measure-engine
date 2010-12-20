module QME
  module Importer
    module Measure
      # Extracts information relevant to calculating Preventive Care and Screening Measure Pair: 
      # a. Tobacco Use Assessment and b. Tobacco Cessation Intervention (NQF 0028) from HITSP C32 documents
      # The following XPath expressions are used
      # 
      # For finding problems or conditions in the Problem List section(used to find tobacco use/non-use)
      #    //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.103']/cda:entry/
      # cda:act/cda:entryRelationship/cda:observation
      #
      # For finding procedures anywhere in the document (used to find tobacco use cessation counseling)
      #    //cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.1.29']
      #
      # Finding substanceAdministration elements in the Medications section 
      #     //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.112']/cda:entry/cda:substanceAdministration
      #
      # Finding coded medications within the substanceAdministration and searching for smoking cessation agents
      #    ./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code
      #
      # Finding encounter elements in the Encounters section
      #    //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.127']/cda:entry/cda:encounter
      class TobaccoUseScreening < MeasureBase
        measure :id => '0028', :sub_id => 'a'
        
        def parse(doc)
          measure_info = {}
          sa_elements = doc.xpath("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.112']/cda:entry/cda:substanceAdministration")
          sa_elements.each do |sa_element|
            create_property_from_code(sa_element, "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code",
                                      'cessation_agent', measure_info)
          end
          
          proc_elements = doc.xpath("//cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.1.29']")
          proc_elements.each do |proc_element|
            create_property_from_code(proc_element, "./cda:code", 'cessation_counseling', measure_info)
          end

          encounter_elements(doc) do |encounter_element|
            create_property_from_code(encounter_element, "./cda:code", 'behavior_encounter', measure_info)
            create_property_from_code(encounter_element, "./cda:code", 'occupational_therapy_encounter', measure_info)
            create_property_from_code(encounter_element, "./cda:code", 'office_encounter', measure_info)
            create_property_from_code(encounter_element, "./cda:code", 'psychiatric_encounter', measure_info)
            create_property_from_code(encounter_element, "./cda:code", 'adult_preventive_med_encounter', measure_info)
            create_property_from_code(encounter_element, "./cda:code", 'other_preventive_med_encounter', measure_info)
            create_property_from_code(encounter_element, "./cda:code", 'individual_counseling_encounter', measure_info)
            create_property_from_code(encounter_element, "./cda:code", 'group_counseling_encounter', measure_info)
          end
          
          problem_elements = doc.xpath("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.103']/cda:entry/cda:act/cda:entryRelationship/cda:observation")
          problem_elements.each do |problem_element|
            create_property_from_code(problem_element, "./cda:value", 'tobacco_non_user', measure_info)
              create_property_from_code(problem_element, "./cda:value", 'tobacco_user', measure_info)
          end
          
          measure_info
        end
      end
    end
  end
end