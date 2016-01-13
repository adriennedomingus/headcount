require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/headcount_analyst'

class HeadcountAnalystTest < MiniTest::Test

  def test_headcount_analyst_object_is_instantiated_with_district_repository_object
    ha = HeadcountAnalyst.new(DistrictRepository.new)

    assert ha.dr.class
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

  def test_calculates_average
    ha = HeadcountAnalyst.new(DistrictRepository.new)
    ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')

    assert_equal 0.406, ha.calculate_average(ha.district1)
    assert_equal 0.53, ha.calculate_average(ha.district2)
  end

  def test_calculates_participation_variation_against_state
    ha = HeadcountAnalyst.new(DistrictRepository.new)
    result = 0.766

    assert_equal result, ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
  end

  def test_calculates_participation_varation_between_two_districts
    ha = HeadcountAnalyst.new(DistrictRepository.new)
    result = 0.446

    assert_equal result, ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1')
  end

  def test_calculates_participation_trend_against_state
    ha = HeadcountAnalyst.new(DistrictRepository.new)
    result = {2007=>0.992, 2006=>1.05, 2005=>0.96, 2004=>1.258, 2008=>0.717, 2009=>0.652, 2010=>0.681, 2011=>0.727, 2012=>0.687, 2013=>0.693, 2014=>0.661}
    assert_equal result, ha.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
  end
end
