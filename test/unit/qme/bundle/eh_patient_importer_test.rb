require 'test_helper'

class EHPatientImporterTest < MiniTest::Unit::TestCase
  include QME::DatabaseAccess

  def setup
    get_db['query_cache'].drop()
    collection_fixtures(get_db(), 'measures')
    @workbook = RubyXL::Parser.parse(File.join('test', 'fixtures', 'eh_patient_sheets', 'result_matrix.xlsx'))    
  end

  def test_load
    assert_equal 0, get_db['query_cache'].find().count
    QME::Bundle::EHPatientImporter.load(get_db, @workbook)
    assert_equal 3, get_db['query_cache'].find().count
  end
end