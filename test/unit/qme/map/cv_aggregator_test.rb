require 'test_helper'

class CVAggregatorTest < MiniTest::Unit::TestCase

  def test_median_with_simple_odd_size_set
    calc({90.0 => 1, 4315.0 => 2}, 4315.0)
  end

  def test_median_with_complex_odd_size_set
    calc({0.0 => 5, 25.0 => 2, 50.0 => 8, 100.0 => 6}, 50.0)
  end

  def test_median_with_simple_even_size_set
    calc({50.0 => 1, 100.0 => 1}, 75.0)
  end

  def test_median_with_large_offset_even_size_set
    calc({1.0 => 3, 2.0 => 1, 5.0 => 1, 7.0 => 1, 8.0 => 1, 10.0 => 2, 12.0 => 1}, 6.0)
  end

  def test_median_with_complex_even_size_set
    calc({25.0 => 5, 50.0 => 5, 100.0 => 5, 200.0 => 5}, 75.0)
  end

  def test_median_with_empty_set
    calc({}, 0)
  end

  def test_single_element_set
    calc({1.0 => 1}, 1.0)
  end

  def calc(ft, exp)
    result = QME::MapReduce::CVAggregator.median(ft)
    assert_equal exp, result
  end
end
