require 'test_helper'

class MapReduceExecutorTest < MiniTest::Unit::TestCase
  include QME::DatabaseAccess

  def setup
    importer = QME::Bundle::Importer.new
    importer.import(File.new('test/fixtures/bundles/just_measure_0002.zip'), true)

    collection_fixtures(get_db(), 'records', '_id')
  end

  def test_map_records_into_measure_groups
    executor = QME::MapReduce::Executor.new("2E679CD2-3FEC-4A75-A75A-61403E5EFEE8", nil,
                                            'effective_date' => Time.gm(2012, 10, 16).to_i)
    executor.map_records_into_measure_groups

    assert_equal 2, get_db['patient_cache'].find().count
    assert_equal 1, get_db['patient_cache'].find('value.population' => true).count
    assert_equal 1, get_db['patient_cache'].find('value.population' => false).count
  end

  def test_count_records_in_measure_groups
    executor = QME::MapReduce::Executor.new("2E679CD2-3FEC-4A75-A75A-61403E5EFEE8", nil,
                                            'effective_date' => Time.gm(2012, 10, 16).to_i)
    executor.map_records_into_measure_groups
    executor.count_records_in_measure_groups
    assert_equal 1, get_db['query_cache'].find().count
    doc = get_db['query_cache'].find().first
    assert_equal 1, doc['population']
  end  
end