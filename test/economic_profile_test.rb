require_relative '../lib/economic_profile.rb'
require 'minitest/autorun'
require 'minitest/pride'

class EconomicProfileTest < Minitest::Test

  def test_has_a_name
    e = EconomicProfile.new({:name=>"ADAMS-ARAPAHOE 28J"})
    assert_equal "ADAMS-ARAPAHOE 28J", e.name
  end
end
