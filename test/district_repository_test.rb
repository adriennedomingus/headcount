require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/district_repository'

class DistrictRepositoryTest < MiniTest::Test

  def test_loads_data
    dr = DistrictRepository.new
    dr.load_data

    assert_equal "ADAMS-ARAPAHOE 28J", dr.district_objects[2].name
  end

  def test_find_by_name_method_returns_instantiated_object_name
    dr = DistrictRepository.new
    dr.load_data

    assert_equal , dr.find_by_name("ADAMS-ARAPAHOE 28J")
  end
end
