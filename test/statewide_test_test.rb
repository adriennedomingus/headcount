require_relative '../lib/statewide_test'
require 'minitest/autorun'
require 'minitest/pride'

class StatewideTestTest < Minitest::Test

  def test_has_a_name
    s = StatewideTest.new({:name=>"ADAMS-ARAPAHOE 28J"})
    assert_equal "ADAMS-ARAPAHOE 28J", s.name
  end
end
