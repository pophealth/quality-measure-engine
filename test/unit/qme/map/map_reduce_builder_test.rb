require 'test_helper'

class MapReduceBuilderTest < MiniTest::Unit::TestCase
  include QME::DatabaseAccess

  def setup
    collection_fixtures(get_db(), 'measures')
    @measure_json = QME::QualityMeasure.where({"nqf_id" => '0043'}).first
     load_system_js
  end

  def test_extracting_measure_metadata
    measure = QME::MapReduce::Builder.new(get_db(), @measure_json, 'effective_date' => Time.gm(2010, 9, 19).to_i)
    assert_equal '0043', measure.id
  end

  def test_extracting_parameters
    time = Time.gm(2010, 9, 19).to_i
    measure = QME::MapReduce::Builder.new(get_db(), @measure_json, 'effective_date'=>time)
    assert_equal 1, measure.params.size
    assert measure.params.keys.include?('effective_date')
    assert_equal time, measure.params['effective_date']
  end

  def test_raise_error_when_no_params_provided
    rte = assert_raises(RuntimeError) do
      QME::MapReduce::Builder.new(get_db(), @measure_json, {})
    end
    assert_equal "No value supplied for measure parameter: effective_date", rte.message
  end

  def test_context_building
    vars = {'a'=>10, 'b'=>20}
    context = QME::MapReduce::Builder::Context.new(get_db(), vars)
    binding = context.get_binding
    assert_equal 10, eval("a",binding)
    assert_equal 20, eval("b",binding)
    assert_equal false, eval("enable_logging",binding)
    vars = {'enable_logging'=>true}
    context = QME::MapReduce::Builder::Context.new(get_db(), vars)
    binding = context.get_binding
    assert_equal true, eval("enable_logging",binding)
    vars = {'enable_logging'=>false}
    context = QME::MapReduce::Builder::Context.new(get_db(), vars)
    binding = context.get_binding
    assert_equal false, eval("enable_logging",binding)
  end
end