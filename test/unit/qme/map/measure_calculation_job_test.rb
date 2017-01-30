require 'test_helper'

class MapCalculationJobTest < MiniTest::Unit::TestCase
  include QME::DatabaseAccess

  def setup
    get_db['query_cache'].drop()
    get_db['patient_cache'].drop()
    collection_fixtures(get_db(), 'measures')
    collection_fixtures(get_db(), 'records', '_id')
    collection_fixtures(get_db(), 'bundles')
    load_system_js

    Delayed::Worker.delay_jobs = false
  end

  def test_perform
    options = {'measure_id' => "2E679CD2-3FEC-4A75-A75A-61403E5EFEE8",
               'effective_date' => Time.gm(2011, 1, 15).to_i}
    qr = QME::QualityReport.find_or_create_by(options)
    job = Delayed::Job.enqueue(QME::MapReduce::MeasureCalculationJob.new({'quality_report_id' => qr.id,"oid_dictionary"=>{}}))
    assert job
  end

  def test_perform_recalculate
    options = {
      'measure_id' => '2E679CD2-3FEC-4A75-A75A-61403E5EFEE8',
      'effective_date' => Time.gm(2011, 1, 15).to_i,
    }

    qr = QME::QualityReport.find_or_create_by(options)
    job = QME::MapReduce::MeasureCalculationJob.new(
      {
        'quality_report_id' => qr.id,
        'oid_dictionary' => {},
        'recalculate' => true
      }
    )
    job.perform
    job.perform # Perform second time to expire the originals

    assert_equal 4, qr.patient_results.count
    assert_equal(
      4, QME::PatientCache.where(:'value.expired_at'.exists => true).count
    )
  end

  def test_perform_no_recalculate
    options = {
      'measure_id' => '2E679CD2-3FEC-4A75-A75A-61403E5EFEE8',
      'effective_date' => Time.gm(2011, 1, 15).to_i,
      'status.state' => 'complete'
    }

    qr = QME::QualityReport.find_or_create_by(options)
    job = QME::MapReduce::MeasureCalculationJob.new(
      {
        'quality_report_id' => qr.id,
        'oid_dictionary' => {},
        'recalculate' => false
      }
    )
    job.perform
    job.perform

    assert_equal 4, qr.patient_results.count
    assert_equal(
      0, QME::PatientCache.where(:'value.expired_at'.exists => true).count
    )
  end
end
