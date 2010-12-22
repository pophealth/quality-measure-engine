module QME
  module Importer
    class GenericImporter
      def initialize(definition)
        @definition = definition
      end
      
      def parse(doc)
        measure_info = {}
        
        @definition['measure'].each_pair do |property, description|
          importers = importers_for_categories(description['standard_categories'])
          measure_info[property] = importers.reduce([]) do |memo, importer|
            memo + importer.extract(doc, description)
          end
        end
        
        measure_info
      end
      
      def importers_for_categories(standard_categories)
        standard_categories.reduce([]) do |memo, category|
          case category
          when 'encounter'; memo << QME::Importer::Section::EncounterImporter
          when 'procedure'; memo << QME::Importer::Section::ProcedureImporter
          when 'laboratory_test'; memo << QME::Importer::Section::ResultImporter
          when 'physical_exam'; memo << QME::Importer::Section::VitalSignImporter
          when 'medication'; memo << QME::Importer::Section::MedicationImporter
          when 'diagnosis_condition_problem'; memo << QME::Importer::Section::ConditionImporter
          end
        end
      end
    end
  end
end