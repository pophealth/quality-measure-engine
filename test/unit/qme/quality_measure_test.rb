require 'test_helper'

class QualityMeasureTest < MiniTest::Unit::TestCase
	include QME::DatabaseAccess
  def setup

    collection_fixtures(get_db(), 'measures')
    collection_fixtures(get_db(), 'bundles')
    load_system_js
  end

  def test_getting_all_measures
    all_measures = QME::QualityMeasure.all
    assert_equal 5, all_measures.size
    assert all_measures["2E679CD2-3FEC-4A75-A75A-61403E5EFEE8.json"]
  end
end