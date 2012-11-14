require 'test_helper'

class EHMeasureSheetTest < MiniTest::Unit::TestCase
  include QME::DatabaseAccess

  def setup
    collection_fixtures(get_db(), 'measures')
    collection_fixtures(get_db(), 'records', '_id')
    @workbook = RubyXL::Parser.parse(File.join('test', 'fixtures', 'eh_patient_sheets', 'results_matrix_eh.xlsx'))
    sheet = @workbook.worksheets[0]
    @ms = QME::Bundle::EHMeasureSheet.new(get_db(), sheet, 12345000)
  end

  def test_extract_measure_info
    measure_info = @ms.extract_measure_info
    assert_equal 'EDD90083-3417-4221-B3B9-52C4E5FAFAF4', measure_info['IPP']
    assert_equal '193A17EC-66B4-4C44-9302-192556C78454', measure_info['DENOM']
  end

  def test_query_cache_document
    @ms.parse
    qcd = @ms.query_cache_document
    assert_equal '0142', qcd['nqf_id']
    assert_equal 4, qcd['population']
    assert_equal 12345000, qcd['effective_date']
  end

  def test_patient_cache_documents
    @ms.parse
    pcd = @ms.patient_cache_documents.first
    assert_equal 1, pcd['value']['population']
    assert_equal 0, pcd['value']['numerator']
    assert_equal 1, pcd['value']['antinumerator']
    assert_equal '1234', pcd['value']['medical_record_id']
    assert_equal 12345000, pcd['value']['effective_date']
  end
end