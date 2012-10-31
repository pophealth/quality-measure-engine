require 'test_helper'

class MapReduceBuilderTest < MiniTest::Unit::TestCase
  include QME::DatabaseAccess

  def setup
    raw_measure_json = File.read(File.join('test', 'fixtures', 'measures', 'measure_metadata.json'))
    @measure_json = JSON.parse(raw_measure_json)
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
  end
end