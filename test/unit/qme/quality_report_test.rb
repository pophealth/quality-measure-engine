require 'test_helper'

class QualityReportTest < MiniTest::Unit::TestCase
  include QME::DatabaseAccess

  def setup
    load_system_js
    collection_fixtures(get_db(), 'bundles')
    collection_fixtures(get_db(), 'records')
    collection_fixtures(get_db(), 'measures')
    get_db()['query_cache'].drop()
    get_db()['patient_cache'].drop()
    get_db()['query_cache'].insert_one({
          "measure_id" => "test2",
          "sub_id" =>  "b",
          "status" =>{"state" => "completed"},
          "initialPopulation" => 4,
          "result" => {
          QME::QualityReport::NUMERATOR => 1,
          QME::QualityReport::DENOMINATOR => 2,
          QME::QualityReport::EXCLUSIONS => 1},
          "effective_date" => Time.gm(2010, 9, 19).to_i}
    )
    get_db()['patient_cache'].insert_one({
          "value" => {
            QME::QualityReport::POPULATION => 0,
            QME::QualityReport::DENOMINATOR => 0,
            QME::QualityReport::NUMERATOR => 0,
            QME::QualityReport::EXCLUSIONS => 0,
            QME::QualityReport::ANTINUMERATOR => 0,
            "medical_record_id" => "0616911582",
            "first" => "Mary",
            "last" => "Edwards",
            "gender" => "F",
            "birthdate" => Time.gm(1940, 9, 19).to_i,
            "test_id" => nil,
            "provider_performances" => nil,
            "race" => {
              "code" => "2106-3",
              "code_set" => "CDC-RE"
            },
            "ethnicity" => {
              "code" => "2135-2",
              "code_set" => "CDC-RE"
            },
            "measure_id" => "test2",
            "sub_id" =>  "b",
            "effective_date" => Time.gm(2010, 9, 19).to_i
          }}
    )
    collection_fixtures(get_db(), 'delayed_backend_mongoid_jobs', '_id')
  end

  def test_calculated
    qr = QME::QualityReport.find_or_create('test2', 'b', "effective_date" => Time.gm(2010, 9, 19).to_i)
    assert qr.calculated?

    qr = QME::QualityReport.find_or_create('test2', 'b', "effective_date" => Time.gm(2010, 9, 20).to_i)
    assert !qr.calculated?
  end

  def test_result
    qr = QME::QualityReport.find_or_create('test2', 'b', "effective_date" => Time.gm(2010, 9, 19).to_i)
    result = qr.result

    assert_equal 1, result[QME::QualityReport::NUMERATOR]
  end

  def test_destroy_all
    QME::QualityReport.destroy_all

    qr = QME::QualityReport.find_or_create('test2', 'b', "effective_date" => Time.gm(2010, 9, 19).to_i)
    assert !qr.calculated?
  end

  def test_update_patient_results
    qr = QME::QualityReport.find_or_create('test2', 'b', "effective_date" => Time.gm(2010, 9, 19).to_i)
    assert qr.calculated?
    assert qr.patients_cached?
    QME::QualityReport.update_patient_results("0616911582")
    qr = QME::QualityReport.find_or_create('test2', 'b', "effective_date" => Time.gm(2010, 9, 19).to_i)
    assert !qr.calculated?
    assert !qr.patients_cached?
  end

  def test_status
    status = QME::MapReduce::MeasureCalculationJob.status('not really a job id')
    assert_equal :complete, status
    status = QME::MapReduce::MeasureCalculationJob.status("508aeff07042f9f88900000d")
    assert_equal :queued, status
  end

  def test_rollup_buffering
    Delayed::Worker.delay_jobs=true
    assert Delayed::Worker.delay_jobs
    Delayed::Job.destroy_all
    QME::QualityReport.destroy_all
    Mongoid.default_client["rollup_buffer"].delete_many({})
    qr = QME::QualityReport.find_or_create('2E679CD2-3FEC-4A75-A75A-61403E5EFEE8', nil, "effective_date" => Time.gm(2011, 9, 19).to_i)
    qr2 = QME::QualityReport.find_or_create('2E679CD2-3FEC-4A75-A75A-61403E5EFEE8', nil, {"effective_date" => Time.gm(2011, 9, 19).to_i,:filters=>{"providers"=>["a"]}})
    assert !qr.calculated?
    assert !qr2.calculated?
    assert_equal 0, Delayed::Job.count()
    assert !qr.patients_cached?
    assert !qr2.patients_cached?

    assert !qr.calculation_queued_or_running?
    assert !qr2.calculation_queued_or_running?

    qr.calculate({"oid_dictionary"=>{}},true)

    assert qr.calculation_queued_or_running?
    assert qr2.calculation_queued_or_running?

    assert_equal 0, Mongoid.default_client["rollup_buffer"].count({})
    qr2.calculate({"oid_dictionary"=>{}},true)
    assert_equal 1, Mongoid.default_client["rollup_buffer"].count({})


    assert_equal 1, Delayed::Job.count()
    job = Delayed::Job.where({}).first
    assert_equal "calculation", job.queue
    job.invoke_job
    job.delete

    assert_equal 1, Delayed::Job.count()
    job = Delayed::Job.where({}).first
    assert_equal "rollup", job.queue

    assert_equal 0, Mongoid.default_client["rollup_buffer"].count({})
  end
end
