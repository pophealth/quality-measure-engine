module QME
  module Bundle
    class EHMeasureSheet
      def initialize(db, sheet)
        @db = db
        @sheet = sheet
      end

      def query_cache_document_for_sheet
        qc_document = {}
        measure_info = extract_measure_info
        qc_document['population_ids'] = measure_info
        measure_doc = @db['measures'].where('population_ids' => measure_info).first
        qc_document['measure_id'] = measure_doc['measure_id']
        qc_document['sub_id'] = measure_doc['sub_id']
        qc_document['nqf_id'] = measure_doc['nqf_id']

        ####
        # Note that the row numbers below will need to change 
        # if more patients are added
        ####
        qc_document['population'] = extract_data_from_cell('C23')
        qc_document['considered'] = 20 # hardcoded to the number of patients in the sheet
        if cv_measure?
          qc_document['msrpopl'] = extract_data_from_cell('E23')
        else
          qc_document['denominator'] = extract_data_from_cell('D23')
          qc_document['numerator'] = extract_data_from_cell('E23')
          qc_document['antinumerator'] = qc_document['denominator'] - qc_document['numerator']
          qc_document['exclusions'] = extract_data_from_cell('F23')
          qc_document['denexcep'] = extract_data_from_cell('G23')
        end

        qc_document['test_id'] = nil
        qc_document['filters'] = nil
        qc_document['execution_time'] = 0

        qc_document
      end

      def extract_measure_info
        measure_info = {}
        measure_info['IPP'] = extract_data_from_cell('I4')
        if cv_measure?
          measure_info['MSRPOPL'] = extract_data_from_cell('I5')
          strat_id = extract_data_from_cell('I6')
          if strat_id.present?
            measure_info['stratification'] = strat_id
          end
        else
          measure_info['DENOM'] = extract_data_from_cell('I5')
          measure_info['NUMER'] = extract_data_from_cell('I6')
          measure_info['DENEX'] = extract_data_from_cell('I7')
          strat_id = extract_data_from_cell('I8')
          if strat_id.present?
            measure_info['stratification'] = strat_id
          end
        end

        measure_info
      end

      def cv_measure?
        extract_data_from_cell('E1').eql?('MSRPOPL')
      end

      private

      def extract_data_from_cell(cell_name)
        row, column = RubyXL::Parser.convert_to_index(cell_name)
        @sheet.sheet_data[row][column].try(:value)
      end
    end

  end
end