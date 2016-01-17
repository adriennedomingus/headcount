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

  def test_calculates_kindergarten_average
    ha = HeadcountAnalyst.new(DistrictRepository.new)
    ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')

    assert_equal 0.407, ha.calculate_kindergarten_average(ha.district1)
    assert_equal 0.53, ha.calculate_kindergarten_average(ha.district2)
  end

  def test_calculates_high_school_graduation_average
    ha = HeadcountAnalyst.new(DistrictRepository.new)
    district = ha.dr.find_by_name("COLORADO")
    district2 = ha.dr.find_by_name("ARCHULETA COUNTY 50 JT")

    assert_equal 0.752, ha.calculate_graduation_average(district)
    assert_equal 0.819, ha.calculate_graduation_average(district2)
  end

  def test_calculates_grdauation_variation
    ha = HeadcountAnalyst.new(DistrictRepository.new)

    assert_equal 1.185, ha.graduation_variation("BOULDER VALLEY RE 2")
  end

  def test_kindergarten_variation_relative_to_colorado
    ha = HeadcountAnalyst.new(DistrictRepository.new)

    assert_equal 0.768, ha.kindergarten_variation("ACADEMY 20")
  end

  def test_kindergarten_graduation_variance
    ha = HeadcountAnalyst.new(DistrictRepository.new)

    assert_equal 0.643, ha.kindergarten_participation_against_high_school_graduation("ACADEMY 20")
  end

  def test_calculates_participation_variation_against_state
    ha = HeadcountAnalyst.new(DistrictRepository.new)
    result = 0.768

    assert_equal result, ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
  end

  def test_calculates_participation_varation_between_two_districts
    ha = HeadcountAnalyst.new(DistrictRepository.new)
    result = 0.448

    assert_equal result, ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1')
  end

  def test_calculates_participation_trend_against_state
    ha = HeadcountAnalyst.new(DistrictRepository.new)
    result = {2007=>0.992, 2006=>1.05, 2005=>0.96, 2004=>1.258, 2008=>0.718, 2009=>0.652, 2010=>0.681, 2011=>0.728, 2012=>0.689, 2013=>0.694, 2014=>0.661}
    assert_equal result, ha.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
  end

  def test_whether_kindergarten_participation_correlates_with_hs_graduation
    ha = HeadcountAnalyst.new(DistrictRepository.new)

    assert ha.kindergarten_participation_correlates_with_high_school_graduation(for: "ACADEMY 20")
    refute ha.kindergarten_participation_correlates_with_high_school_graduation(for: "BENNETT 29J")
  end

  def test_whether_kindergarten_participation_correlates_with_hs_graduation_statewide
    ha = HeadcountAnalyst.new(DistrictRepository.new)

    refute ha.kindergarten_participation_correlates_with_high_school_graduation(for: "STATEWIDE")
  end

  def test_kindergarten_correlation_with_graduation_across_specified_districts
    ha = HeadcountAnalyst.new(DistrictRepository.new)

    refute ha.kindergarten_participation_correlates_with_high_school_graduation(across: ["BENNETT 29J", "ACADEMY 20"])
  end

  def test_kindergarten_correlation_with_graduation_across_specified_districts
    ha = HeadcountAnalyst.new(DistrictRepository.new)

    refute ha.kindergarten_participation_correlates_with_high_school_graduation(across: ["BOULDER VALLEY RE 2", "ACADEMY 20", "BETHUNE R-5", "BUFFALO RE-4", "PLATEAU VALLEY 50"])
  end
end
