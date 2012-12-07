require 'test_helper'

class MapCalculationJobTest < MiniTest::Unit::TestCase
  include QME::DatabaseAccess

  def setup
    importer = QME::Bundle::Importer.new
    importer.import(File.new('test/fixtures/bundles/just_measure_0002.zip'), nil, true)

    collection_fixtures(get_db(), 'records', '_id')

    Delayed::Worker.delay_jobs = false
  end

  def test_perform
    options = {'measure_id' => "2E679CD2-3FEC-4A75-A75A-61403E5EFEE8",
               'effective_date' => Time.gm(2011, 1, 15).to_i}

    job = Delayed::Job.enqueue(QME::MapReduce::MeasureCalculationJob.new(options))
    assert job
  end
end