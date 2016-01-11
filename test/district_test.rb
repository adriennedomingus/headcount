require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/district'

class DistrictTest < MiniTest::Test

  def test_test
    d = District.new({:name => "ACADEMY 20"})
    
    assert_equal "ACADEMY 20", d.name
  end
end
