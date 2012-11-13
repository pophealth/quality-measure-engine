module QME
  module Bundle
    class EHMeasureSheet
      attr_reader :query_cache_document, :patient_cache_documents,
                  :patient_updates

      def initialize(db, sheet, effective_date=nil)
        @db = db
        @sheet = sheet
        @effective_date = effective_date
        @patient_cache_documents = []
        @patient_updates = []
      end

      def parse
        qc_document = {}
        measure_info = extract_measure_info
        qc_document['population_ids'] = measure_info
        measure_doc = @db['measures'].where('population_ids' => measure_info).first
        measure_ids = measure_doc.slice('sub_id', 'nqf_id')
        measure_ids['measure_id'] = measure_doc['hqmf_id']
        qc_document.merge!(measure_ids)
        extract_patients(measure_ids)

        qc_document['population'] = extract_data_from_cell("C#{@population_totals_row}")
        qc_document['considered'] = @population_totals_row - 3 # header row, blank row and totals row
        if cv_measure?
          qc_document['msrpopl'] = extract_data_from_cell("E#{@population_totals_row}")
        else
          qc_document['denominator'] = extract_data_from_cell("D#{@population_totals_row}")
          qc_document['numerator'] = extract_data_from_cell("E#{@population_totals_row}")
          qc_document['antinumerator'] = qc_document['denominator'] - qc_document['numerator']
          qc_document['exclusions'] = extract_data_from_cell("F#{@population_totals_row}")
          qc_document['denexcep'] = extract_data_from_cell("G#{@population_totals_row}")
        end

        qc_document['test_id'] = nil
        qc_document['filters'] = nil
        qc_document['execution_time'] = 0
        qc_document['effective_date'] = @effective_date

        @query_cache_document = qc_document
      end

      def extract_patients(measure_ids)
        row = 2
        medical_record_number = extract_data_from_cell("B#{row}")
        while medical_record_number.present?
          patient_document = extract_patient(row, medical_record_number.to_s)
          patient_document.merge!(measure_ids)
          @patient_cache_documents << {'value' => patient_document}
          @patient_updates << {'medical_record_number' => medical_record_number.to_s,
                               'measure_id' => measure_ids['measure_id']}
          row = row + 1
          medical_record_number = extract_data_from_cell("B#{row}")
        end

        @population_totals_row = row + 1
      end

      def extract_measure_info
        measure_info = {}
        measure_info['IPP'] = extract_data_from_cell('I5')
        if cv_measure?
          measure_info['MSRPOPL'] = extract_data_from_cell('I10')
          measure_info['stratification'] = extract_data_from_cell('I11') if extract_data_from_cell('I11').present?
        else
          measure_info['DENOM'] = extract_data_from_cell('I6')
          measure_info['NUMER'] = extract_data_from_cell('I7')
          measure_info['DENEXCEP'] = extract_data_from_cell('I8') if extract_data_from_cell('I8').present?
          measure_info['DENEX'] = extract_data_from_cell('I9') if extract_data_from_cell('I9').present?
          measure_info['stratification'] = extract_data_from_cell('I11') if extract_data_from_cell('I11').present?
        end

        measure_info
      end

      def extract_patient(row, medical_record_number)
        record = @db['records'].where('medical_record_number' => medical_record_number).first
        patient_document = record.slice('first', 'last', 'gender', 'birthdate', 'race',
                                              'ethnicity', 'languages')
        patient_document['medical_record_id'] = medical_record_number
        patient_document['patient_id'] = record['_id'].to_s
        patient_document['population'] = extract_data_from_cell("C#{row}") || 0
        if cv_measure?
          patient_document['values'] = [extract_data_from_cell("E#{row}")]
        else
          patient_document['denominator'] = extract_data_from_cell("D#{row}") || 0
          patient_document['numerator'] = extract_data_from_cell("E#{row}") || 0
          patient_document['exclusions'] = extract_data_from_cell("F#{row}") || 0
          patient_document['denexcep'] = extract_data_from_cell("G#{row}") || 0

        end
        patient_document['test_id'] = nil
        patient_document['effective_date'] = @effective_date

        patient_document
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