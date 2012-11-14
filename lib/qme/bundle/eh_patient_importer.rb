module QME
  module Bundle
    class EHPatientImporter
      def self.load(db, spreadsheet, effective_date=nil)
        spreadsheet.worksheets.each do |worksheet|
          ms = EHMeasureSheet.new(db, worksheet, effective_date)
          ms.parse
          qc_document = ms.query_cache_document
          db['query_cache'].insert(qc_document)
          ms.patient_cache_documents.each do |pcd|
            db['patient_cache'].insert(pcd)
          end
          ms.patient_updates.each do |patient_update|
            db['records'].find('medical_record_number' => patient_update['medical_record_number']).update(
                               '$push' => {'measure_ids' => patient_update['measure_id']})
          end
        end
      end
    end
  end
end