require 'test_helper'

class MapReduceExecutorTest < MiniTest::Unit::TestCase
  include QME::DatabaseAccess

  def setup

    get_db['query_cache'].drop()
    get_db['patient_cache'].drop()
    collection_fixtures(get_db(), 'measures')
    collection_fixtures(get_db(), 'records', '_id')
    collection_fixtures(get_db(), 'bundles')
    load_system_js
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


 def test_calculate_supplemental_data_elements
    executor = QME::MapReduce::Executor.new("2E679CD2-3FEC-4A75-A75A-61403E5EFEE8", nil,
                                            'effective_date' => Time.gm(2011, 1, 15).to_i)
                                            
    executor.map_records_into_measure_groups
    executor.count_records_in_measure_groups
    assert_equal 1, get_db['query_cache'].find().count
    doc = get_db['query_cache'].find().first
    suppl = doc["supplemental_data"]
    assert !suppl.empty?, "should contain supplemental data entries"
    ipp = {QME::QualityReport::RACE =>{""=>3},
     QME::QualityReport::ETHNICITY => {""=>3},
     QME::QualityReport::PAYER => {""=>3},
     QME::QualityReport::SEX => {"F"=>2,"M"=>1}
     }

     denom = {QME::QualityReport::RACE =>{""=>2},
     QME::QualityReport::ETHNICITY => {""=>2},
     QME::QualityReport::PAYER => {""=>2},
     QME::QualityReport::SEX => {"F"=>2}
     }

     numer = {QME::QualityReport::RACE =>{""=>1},
     QME::QualityReport::ETHNICITY => {""=>1},
     QME::QualityReport::PAYER => {""=>1},
     QME::QualityReport::SEX => {"F"=>1}
     }

     

    assert_equal ipp, suppl[QME::QualityReport::POPULATION]
    assert_equal denom, suppl[QME::QualityReport::DENOMINATOR]
    assert_equal numer, suppl[QME::QualityReport::NUMERATOR]

   
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