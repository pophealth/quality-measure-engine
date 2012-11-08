require 'test_helper'

class EHMeasureSheetTest < MiniTest::Unit::TestCase
  include QME::DatabaseAccess

  def setup
    collection_fixtures(get_db(), 'measures')
    @workbook = RubyXL::Parser.parse(File.join('test', 'fixtures', 'eh_patient_sheets', 'result_matrix.xlsx'))    
  end

  def test_extract_measure_info
    sheet = @workbook.worksheets[0]
    ms = QME::Bundle::EHMeasureSheet.new(get_db(), sheet)
    measure_info = ms.extract_measure_info
    assert_equal 'EDD90083-3417-4221-B3B9-52C4E5FAFAF4', measure_info['IPP']
    assert_equal '193A17EC-66B4-4C44-9302-192556C78454', measure_info['DENOM']
  end

  def test_query_cache_document_for_sheet
    sheet = @workbook.worksheets[0]
    ms = QME::Bundle::EHMeasureSheet.new(get_db(), sheet)
    qcd = ms.query_cache_document_for_sheet
    assert_equal '0142', qcd['nqf_id']
    assert_equal 4, qcd['population']
  end
end