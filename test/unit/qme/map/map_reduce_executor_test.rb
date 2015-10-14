require 'test_helper'

class MapReduceExecutorTest < MiniTest::Unit::TestCase
  include QME::DatabaseAccess

  def setup

    get_db['query_cache'].drop()
    get_db['patient_cache'].drop()
    collection_fixtures(get_db(), 'measures')
    collection_fixtures(get_db(), 'records', '_id')
    collection_fixtures(get_db(), 'bundles')
    options = {'measure_id' => "2E679CD2-3FEC-4A75-A75A-61403E5EFEE8",
               'effective_date' => Time.gm(2011, 1, 15).to_i}
    @quality_report =QME::QualityReport.find_or_create_by(options)
    load_system_js
  end

  def test_map_records_into_measure_groups
    executor = QME::MapReduce::Executor.new(@quality_report.measure_id,@quality_report.sub_id, {
                                            'effective_date' => Time.gm(2011, 1, 15).to_i})

    executor.map_records_into_measure_groups


    assert_equal 4, get_db['patient_cache'].find().count
    assert_equal 3, get_db['patient_cache'].find("value.#{QME::QualityReport::POPULATION}" => 1).count
    assert_equal 1, get_db['patient_cache'].find("value.#{QME::QualityReport::POPULATION}" => 0).count
    assert_equal 2, get_db['patient_cache'].find("value.#{QME::QualityReport::DENOMINATOR}" => 1).count
    assert_equal 1, get_db['patient_cache'].find("value.#{QME::QualityReport::NUMERATOR}" => 1).count
  end


  def test_calculate_supplemental_data_elements
    executor = QME::MapReduce::Executor.new(@quality_report.measure_id,@quality_report.sub_id, {
                                            'effective_date' => Time.gm(2011, 1, 15).to_i})

    executor.map_records_into_measure_groups
    result = executor.count_records_in_measure_groups

    suppl = result["supplemental_data"]

    assert !suppl.empty?, "should contain supplemental data entries"
    ipp = {QME::QualityReport::RACE =>{"UNK"=>2, "1002-5"=>1},
     QME::QualityReport::ETHNICITY => {"UNK"=>1, "2186-5"=>2},
     QME::QualityReport::PAYER => {"UNK"=>3},
     QME::QualityReport::SEX => {"F"=>2,"M"=>1}
     }

     denom = {QME::QualityReport::RACE =>{"UNK"=>1, "1002-5"=>1},
     QME::QualityReport::ETHNICITY => { "2186-5"=>2},
     QME::QualityReport::PAYER => {"UNK"=>2},
     QME::QualityReport::SEX => {"F"=>2}
     }

     numer = {QME::QualityReport::RACE =>{"UNK"=>1},
     QME::QualityReport::ETHNICITY => {"2186-5"=>1},
     QME::QualityReport::PAYER => {"UNK"=>1},
     QME::QualityReport::SEX => {"F"=>1}
     }



    assert_equal ipp, suppl[QME::QualityReport::POPULATION]
    assert_equal denom, suppl[QME::QualityReport::DENOMINATOR]
    assert_equal numer, suppl[QME::QualityReport::NUMERATOR]


  end

  def test_count_records_in_measure_groups
    executor = QME::MapReduce::Executor.new(@quality_report.measure_id,@quality_report.sub_id, {
                                            'effective_date' => Time.gm(2011, 1, 15).to_i})
    executor.map_records_into_measure_groups
    result = executor.count_records_in_measure_groups
    assert_equal 3, result[QME::QualityReport::POPULATION]
    assert_equal 2, result[QME::QualityReport::DENOMINATOR]
    assert_equal 1, result[QME::QualityReport::NUMERATOR]

    executor = QME::MapReduce::Executor.new(@quality_report.measure_id,@quality_report.sub_id, {
                                            'effective_date' => Time.gm(2011, 1, 14).to_i})

    result = executor.count_records_in_measure_groups
    assert_equal 0, result[QME::QualityReport::POPULATION]
    assert_equal 0, result[QME::QualityReport::DENOMINATOR]
    assert_equal 0, result[QME::QualityReport::NUMERATOR]
  end

  def test_map_record_into_measure_groups
    executor = QME::MapReduce::Executor.new( @quality_report.measure_id,@quality_report.sub_id, {
                                            'effective_date' => Time.gm(2011, 1, 15).to_i})
    executor.map_record_into_measure_groups("12345")

    assert_equal 1, QME::PatientCache.count
    assert_equal 1, QME::PatientCache.where("value.#{QME::QualityReport::POPULATION}" => 1).count
    assert_equal 0, QME::PatientCache.where("value.#{QME::QualityReport::POPULATION}" => 0).count
    assert_equal 1, QME::PatientCache.where("value.#{QME::QualityReport::DENOMINATOR}" => 1).count
    assert_equal 1, QME::PatientCache.where("value.#{QME::QualityReport::NUMERATOR}" => 1).count
  end

  def test_get_patient_result
    executor = QME::MapReduce::Executor.new(@quality_report.measure_id,@quality_report.sub_id, {
                                            'effective_date' => Time.gm(2011, 1, 15).to_i})
    result = executor.get_patient_result("12345")
    assert_equal 0, QME::PatientCache.count
    assert result[QME::QualityReport::NUMERATOR]
  end

  def test_provider_assignment
    executor = QME::MapReduce::Executor.new(@quality_report.measure_id,@quality_report.sub_id, {
                                            'effective_date' => Time.gm(2011, 1, 15).to_i})
    executor.map_records_into_measure_groups
    assert_equal 4, get_db['patient_cache'].find("value.provider_performances" => {'$size' => 1}).count
    assert_equal 1, QME::PatientCache.where('value.medical_record_id' => '12345', 'value.provider_performances.provider_id' => 'too_early_provider').count
  end

  def test_get_patient_result_with_bundle_id
    measure_id = "2E679CD2-3FEC-4A75-A75A-61403E5EFEE8"
    bundle_id = get_db()['bundles'].find.first
    get_db()['measures'].update_many({'id' => measure_id}, {:$set => {'bundle_id' => bundle_id}})
    executor = QME::MapReduce::Executor.new(measure_id, nil,
                                            'effective_date' => Time.gm(2011, 1, 15).to_i, 'bundle_id' => bundle_id)
    result = executor.get_patient_result("12345")
    assert_equal 0, get_db['patient_cache'].find().count
    assert result[QME::QualityReport::NUMERATOR]
  end

end