require 'simplecov'
SimpleCov.start
require_relative '../lib/result_entry'
require 'minitest/autorun'
require 'minitest/pride'

class ResultEntryTest < MiniTest::Test

  def test_has_methods
    r1 = ResultEntry.new({free_and_reduced_price_lunch_rate: 0.5,
    children_in_poverty_rate: 0.25,
    high_school_graduation_rate: 0.75})

    assert_equal 0.5, r1.free_and_reduced_price_lunch_rate
    assert_equal 0.25, r1.children_in_poverty_rate
    assert_equal 0.75, r1.high_school_graduation_rate
    assert_equal nil, r1.median_household_income
  end
end
