module QME
  module Importer
    module Measure
      # Extracts information relevant to calculating Controlling High Blood Pressure (NQF 0018) from HITSP C32 documents
      # The following XPath expressions are used
      # 
      # For finding problems or conditions in the Problem List section(used to find hypertension, ESRD, and pregnancy)
      #    //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.103']/cda:entry/
      #cda:act/cda:entryRelationship/cda:observation
      #
      # Finding encounter elements in the Encounters section. This is used to find outpatient encounters
      #    //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.127']/cda:entry/cda:encounter
      #
      # For finding procedures anywhere in the document (used to find procedures indicative of ESRD)
      #    //cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.1.29']
      #
      # For finding vital sign observations(used to find systolic and diastolic blood pressure)
      #    //cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.14']
      class HighBloodPressure < MeasureBase
        
        def parse(doc)
          measure_info = {}
          
          problem_elements = doc.xpath("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.103']/cda:entry/cda:act/cda:entryRelationship/cda:observation")
          problem_elements.each do |problem_element|
            create_property_from_code(problem_element, "./cda:value", 'hypertension', measure_info)
            create_property_from_code(problem_element, "./cda:value", 'esrd', measure_info)
            create_property_from_code(problem_element, "./cda:value", 'pregnancy', measure_info)
          end
          
          encounter_elements = doc.xpath("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.127']/cda:entry/cda:encounter")
          encounter_elements.each do |encounter_element|
            create_property_from_code(encounter_element, "./cda:code", 'encounter_outpatient', measure_info)
          end
          
          proc_elements = doc.xpath("//cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.1.29']")
          proc_elements.each do |proc_element|
            create_property_from_code(proc_element, "./cda:code", 'procedures_indicative_of_esrd', measure_info)
          end
          
          observation_elements = doc.xpath("//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.14']")
          observation_elements.each do |observation_element|
            create_property_from_code(observation_element, "./cda:code", 'systolic_blood_pressure', measure_info)
            extract_property_value(observation_element, "./cda:code", 'systolic_blood_pressure', measure_info)
            create_property_from_code(observation_element, "./cda:code", 'diastolic_blood_pressure', measure_info)  
            extract_property_value(observation_element, "./cda:code", 'diastolic_blood_pressure', measure_info)
          end
          
          measure_info
        end
      end
    end
  end
end