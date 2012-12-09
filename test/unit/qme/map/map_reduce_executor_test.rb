require 'test_helper'

class MapReduceExecutorTest < MiniTest::Unit::TestCase
  include QME::DatabaseAccess

  def setup
    importer = QME::Bundle::Importer.new
    importer.import(File.new('test/fixtures/bundles/just_measure_0002.zip'), nil, true)

    collection_fixtures(get_db(), 'records', '_id')
  end

  def test_map_records_into_measure_groups
    executor = QME::MapReduce::Executor.new("2E679CD2-3FEC-4A75-A75A-61403E5EFEE8", nil,
                                            'effective_date' => Time.gm(2011, 1, 15).to_i)
                                            
    executor.map_records_into_measure_groups

    assert_equal 4, get_db['patient_cache'].find().count
    assert_equal 3, get_db['patient_cache'].find("value.#{QME::QualityReport::POPULATION}" => 1).count
    assert_equal 1, get_db['patient_cache'].find("value.#{QME::QualityReport::POPULATION}" => 0).count
    assert_equal 2, get_db['patient_cache'].find("value.#{QME::QualityReport::DENOMINATOR}" => 1).count
    assert_equal 1, get_db['patient_cache'].find("value.#{QME::QualityReport::NUMERATOR}" => 1).count
  end

  def test_count_records_in_measure_groups
    executor = QME::MapReduce::Executor.new("2E679CD2-3FEC-4A75-A75A-61403E5EFEE8", nil,
                                            'effective_date' => Time.gm(2011, 1, 15).to_i)
    executor.map_records_into_measure_groups
    executor.count_records_in_measure_groups
    assert_equal 1, get_db['query_cache'].find().count
    doc = get_db['query_cache'].find().first
    assert_equal 3, doc[QME::QualityReport::POPULATION]
    assert_equal 2, doc[QME::QualityReport::DENOMINATOR]
    assert_equal 1, doc[QME::QualityReport::NUMERATOR]
  end

  def test_map_record_into_measure_groups
    executor = QME::MapReduce::Executor.new("2E679CD2-3FEC-4A75-A75A-61403E5EFEE8", nil,
                                            'effective_date' => Time.gm(2011, 1, 15).to_i)
    executor.map_record_into_measure_groups("12345")

    assert_equal 1, get_db['patient_cache'].find().count
    assert_equal 1, get_db['patient_cache'].find("value.#{QME::QualityReport::POPULATION}" => 1).count
    assert_equal 0, get_db['patient_cache'].find("value.#{QME::QualityReport::POPULATION}" => 0).count
    assert_equal 1, get_db['patient_cache'].find("value.#{QME::QualityReport::DENOMINATOR}" => 1).count
    assert_equal 1, get_db['patient_cache'].find("value.#{QME::QualityReport::NUMERATOR}" => 1).count
  end

  def test_get_patient_result
    executor = QME::MapReduce::Executor.new("2E679CD2-3FEC-4A75-A75A-61403E5EFEE8", nil,
                                            'effective_date' => Time.gm(2011, 1, 15).to_i)
    result = executor.get_patient_result("12345")
    assert_equal 0, get_db['patient_cache'].find().count
    assert result[QME::QualityReport::NUMERATOR]
  end
end