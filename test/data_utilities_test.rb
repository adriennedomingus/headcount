require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/district_repository'

class DataUtilitiesTest < MiniTest::Test

  def test_truncates_values
    assert_equal 52.426, DataUtilities.truncate_value(52.425992134)
    assert_equal 52.4, DataUtilities.truncate_value(52.4)
    assert_equal 0.421, DataUtilities.truncate_value(0.42138492312)
  end

  def test_opens_csvs
    assert DataUtilities.open_csv("./data/Kindergartners in full-day program.csv").is_a?(CSV)
  end
end
