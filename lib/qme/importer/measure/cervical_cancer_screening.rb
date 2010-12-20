module QME
  module Importer
    module Measure
      # Extracts information relevant to calculating Cervical Cancer Screening (NQF 0032) from HITSP C32 documents
      # The following XPath expressions are used
      #
      # Finding encounter elements in the Encounters section. This is used to find both outpatient and
      # OB/GYN encounters
      #    //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.127']/cda:entry/cda:encounter
      #
      # For finding procedures anywhere in the document (used to find a hysterectomy procedure)
      #    //cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.1.29']
      #
      # For finding result observations (to see if a pap test has been performed)
      #    //cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.15']
      class CervicalCancerScreening < MeasureBase
        measure :id => '0032'
        
        def parse(doc)
          measure_info = {}
          
          encounter_elements = doc.xpath("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.127']/cda:entry/cda:encounter")
          encounter_elements.each do |encounter_element|
            create_property_from_code(encounter_element, "./cda:code", 'encounter_outpatient', measure_info)
            create_property_from_code(encounter_element, "./cda:code", 'encounter_obgyn', measure_info)
          end
          
          proc_elements = doc.xpath("//cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.1.29']")
          proc_elements.each do |proc_element|
            create_property_from_code(proc_element, "./cda:code", 'hysterectomy', measure_info)
          end
          
          observation_elements = doc.xpath("//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.15']")
          observation_elements.each do |observation_element|
            create_property_from_code(observation_element, "./cda:code", 'pap_test', measure_info)
          end
          
          measure_info
        end
      end
    end
  end
end