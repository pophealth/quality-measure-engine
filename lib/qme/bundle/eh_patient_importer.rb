module QME
  module Bundle
    class EHPatientImporter
      def self.load(db, spreadsheet)
        spreadsheet.worksheets.each do |worksheet|
          ms = EHMeasureSheet.new(db, worksheet)
          qc_document = ms.query_cache_document_for_sheet
          db['query_cache'].insert(qc_document)
        end
      end
    end
  end
end