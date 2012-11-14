require 'test_helper'

class EHPatientImporterTest < MiniTest::Unit::TestCase
  include QME::DatabaseAccess

  def setup
    get_db['query_cache'].drop()
    get_db['patient_cache'].drop()
    collection_fixtures(get_db(), 'measures')
    collection_fixtures(get_db(), 'records', '_id')
    @workbook = RubyXL::Parser.parse(File.join('test', 'fixtures', 'eh_patient_sheets', 'results_matrix_eh.xlsx'))    
  end

  def test_load
    assert_equal 0, get_db['query_cache'].find().count
    QME::Bundle::EHPatientImporter.load(get_db, @workbook)
    assert_equal 3, get_db['query_cache'].find().count
    assert_equal 12, get_db['patient_cache'].find().count
  end
end