require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/headcount_analyst'

class HeadcountAnalystTest < MiniTest::Test

  def setup
    @ha = HeadcountAnalyst.new(DistrictRepository.new)
  end

  def test_headcount_analyst_object_is_instantiated_with_district_repository_object
    assert @ha.dr.class
  end

  def test_instantiating_ha_creates_district_repository_with_data_in_it
    assert_equal "ADAMS-ARAPAHOE 28J", @ha.dr.district_objects[2].name
  end

  def test_can_find_by_name_each_district_passed_to_kindergarten_participation_rate_variation
    @ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')

    assert_equal "ACADEMY 20", @ha.district1.name
    assert_equal "COLORADO", @ha.district2.name
  end

  def test_calculates_kindergarten_average
    @ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')

    assert_equal 0.407, @ha.calculate_kindergarten_average(@ha.district1)
    assert_equal 0.53, @ha.calculate_kindergarten_average(@ha.district2)
  end

  def test_calculates_high_school_graduation_average
    district = @ha.dr.find_by_name("COLORADO")
    district2 = @ha.dr.find_by_name("ARCHULETA COUNTY 50 JT")

    assert_equal 0.752, @ha.calculate_graduation_average(district)
    assert_equal 0.819, @ha.calculate_graduation_average(district2)
  end

  def test_calculates_grdauation_variation
    assert_equal 1.185, @ha.graduation_variation("BOULDER VALLEY RE 2")
  end

  def test_kindergarten_variation_relative_to_colorado
    assert_equal 0.768, @ha.kindergarten_variation("ACADEMY 20")
  end

  def test_kindergarten_graduation_variance
    assert_equal 0.643, @ha.kindergarten_participation_against_high_school_graduation("ACADEMY 20")
  end

  def test_calculates_participation_variation_against_state
    result = 0.768

    assert_equal result, @ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
  end

  def test_calculates_participation_varation_between_two_districts
    result = 0.448

    assert_equal result, @ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1')
  end

  def test_calculates_participation_trend_against_state
    result = {2007=>0.992, 2006=>1.05, 2005=>0.96, 2004=>1.258, 2008=>0.718, 2009=>0.652, 2010=>0.681, 2011=>0.728, 2012=>0.689, 2013=>0.694, 2014=>0.661}
    assert_equal result, @ha.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
  end

  def test_whether_kindergarten_participation_correlates_with_hs_graduation
    assert @ha.kindergarten_participation_correlates_with_high_school_graduation(for: "ACADEMY 20")
    refute @ha.kindergarten_participation_correlates_with_high_school_graduation(for: "BENNETT 29J")
  end

  def test_whether_kindergarten_participation_correlates_with_hs_graduation_statewide
    refute @ha.kindergarten_participation_correlates_with_high_school_graduation(for: "STATEWIDE")
  end

  def test_kindergarten_graduation_correlation
    assert @ha.kindergarten_graduation_correlation("COLORADO")
  end

  def test_kindergarten_correlation_with_graduation_across_specified_districts
    refute @ha.kindergarten_participation_correlates_with_high_school_graduation(across: ["BENNETT 29J", "ACADEMY 20"])
    refute @ha.kindergarten_participation_correlates_with_high_school_graduation(across: ["BOULDER VALLEY RE 2", "ACADEMY 20", "BETHUNE R-5", "BUFFALO RE-4", "PLATEAU VALLEY 50"])
  end

  def test_calculate_average_frl
    district = @ha.dr.find_by_name("ACADEMY 20")

    assert_equal 0.085, @ha.calculate_average_frl_number(district)
  end

  def test_calculate_average_percent_of_children_in_poverty
    district = @ha.dr.find_by_name("ACADEMY 20")

    assert_equal 0.041, @ha.calculate_avarage_percent_of_children_in_poverty(district)
  end

  def test_calculates_average_of_median_household_incomes
    district = @ha.dr.find_by_name("ACADEMY 20")
    state = @ha.dr.find_by_name("COLORADO")

    assert_equal 57408.0, @ha.calculate_average_of_median_household_income(state)
    assert_equal 87635.4, @ha.calculate_average_of_median_household_income(district)
  end

  def test_calculates_median_household_income_variation
    assert_equal 1.527, @ha.median_household_income_variation("ACADEMY 20")
  end

  def test_kindergarten_participation_against_household_income
    assert_equal 0.503, @ha.kindergarten_participation_against_household_income("ACADEMY 20")
  end

  def test_kindergarten_and_income_correlation_returns_true_or_false
    refute @ha.true_or_false_kindergarten_correlates_with_income("ACADEMY 20")
  end

  def test_whether_kindergarten_participation_correlates_with_income
    refute @ha.kindergarten_participation_correlates_with_household_income(for: "ACADEMY 20")
    refute @ha.kindergarten_participation_correlates_with_household_income(for: "BENNETT 29J")
  end

  def test_kindergarten_correlation_with_income_across_specified_districts
    refute @ha.kindergarten_participation_correlates_with_household_income(across: ["BOULDER VALLEY RE 2", "ACADEMY 20"])
  end

  def test_kindergarten_correlation_with_income_statewide
    refute @ha.kindergarten_participation_correlates_with_household_income(for: "STATEWIDE")
  end

  def test_high_poverty_and_high_school_graduation
    assert_equal 0.529, @ha.high_poverty_and_high_school_graduation.matching_districts[4].free_and_reduced_price_lunch_rate

    assert @ha.high_poverty_and_high_school_graduation.is_a?(ResultSet)
  end

  def test_high_income_disparity
    assert_equal 71091.2, @ha.high_income_disparity.matching_districts[1].median_household_income

    assert @ha.high_income_disparity.is_a?(ResultSet)
  end
end
