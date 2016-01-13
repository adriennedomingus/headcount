require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/headcount_analyst'

class HeadcountAnalystTest < MiniTest::Test

  def test_headcount_analyst_object_is_instantiated_with_district_repository_object
    ha = HeadcountAnalyst.new(DistrictRepository.new)

    assert ha.dr.class

    #then you can average over the years and compare
  end

  def test_instantiating_ha_creates_district_repository_with_data_in_it
    ha = HeadcountAnalyst.new(DistrictRepository.new)

    assert_equal "ADAMS COUNTY 14", ha.dr.district_objects[2].name
  end

  def test_can_find_by_name_each_district_passed_to_kindergarten_participation_rate_variation
    ha = HeadcountAnalyst.new(DistrictRepository.new)
    ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')

    assert_equal "ACADEMY 20", ha.district1.name
    assert_equal "COLORADO", ha.district2.name
  end
end
