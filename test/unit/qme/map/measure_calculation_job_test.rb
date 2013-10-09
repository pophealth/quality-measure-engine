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
end