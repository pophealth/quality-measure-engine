require 'test_helper'

class EffectiveStartDateInjectorTest < MiniTest::Unit::TestCase
  def setup
    @map_fn = <<-MAP_FN
      var effective_date = <%= effective_date %>;
      MeasurePeriod.low.date = new Date(1000*(effective_date+60));\n  MeasurePeriod.low.date.setFullYear(MeasurePeriod.low.date.getFullYear()-1);",
    MAP_FN
  end

  def test_execute_no_effective_start_date
    subject = QME::MapReduce::EffectiveStartDateInjector.new(
      map_fn: @map_fn,
      effective_start_date: nil
    )

    assert_equal subject.execute, @map_fn
  end

  def test_execute_with_effective_start_date
    subject = QME::MapReduce::EffectiveStartDateInjector.new(
      map_fn: @map_fn,
      effective_start_date: "foo"
    )

    expected = <<-EXPECTED
      var effective_date = <%= effective_date %>; var effective_start_date = <%= effective_start_date %>;
      MeasurePeriod.low.date = new Date(1000*effective_start_date);\",
    EXPECTED

    assert_equal subject.execute, expected
  end
end
