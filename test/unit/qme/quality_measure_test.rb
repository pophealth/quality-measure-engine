require 'test_helper'

class QualityMeasureTest < MiniTest::Unit::TestCase
	include QME::DatabaseAccess

  def setup
    collection_fixtures(get_db(), 'measures')
    collection_fixtures(get_db(), 'bundles')
    @bundle_id = get_db['bundles'].find.first['_id']
    get_db['measures'].find({}).update(:$set => {'bundle_id' => @bundle_id})
    load_system_js
  end

  def test_getting_all_measures_without_bundle_id
    all_measures = QME::QualityMeasure.all
    assert_equal 5, all_measures.size

    assert all_measures["2E679CD2-3FEC-4A75-A75A-61403E5EFEE8.json"]
  end

  def test_getting_definition_with_bundle_id
    result = QME::QualityMeasure.all(@bundle_id).to_a.first.last
    measure = QME::QualityMeasure.new(result['id'], result['sub_id'], @bundle_id)
    assert measure.definition
    assert_equal result['id'], measure.definition['id']
  end

  def test_getting_all_measure_with_bundle_id
    get_db()['measures']
    all_measures = QME::QualityMeasure.all(@bundle_id)

    assert_equal 1, all_measures.size
  end

  def test_getting_measure_subset
    measure_ids = get_db['measures'].find({}).map { |m| m['id'] }
    measure_ids.pop
    
    measures = QME::QualityMeasure.get_measures(measure_ids)
    measure_ids2 = measures.map { |m| m['id'] }
    assert_equal measure_ids.sort, measure_ids2.sort
  end

  def test_getting_sub_measures
    measures = QME::QualityMeasure.sub_measures("8A4D92B2-3887-5DF3-0139-0C4E41594C98")
    assert_equal 2, measures.count
  end

  def test_getting_sub_measure
    measure = QME::QualityMeasure.get("8A4D92B2-3887-5DF3-0139-0C4E41594C98", 'a')
    assert measure
  end

end