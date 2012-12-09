require 'test_helper'

class QualityMeasureTest < MiniTest::Unit::TestCase
  def setup
    importer = QME::Bundle::Importer.new
    importer.import(File.new('test/fixtures/bundles/just_measure_0002.zip'), nil, true)
  end

  def test_getting_all_measures
    all_measures = QME::QualityMeasure.all
    assert_equal 1, all_measures.size
    assert all_measures["2E679CD2-3FEC-4A75-A75A-61403E5EFEE8.json"]
  end
end