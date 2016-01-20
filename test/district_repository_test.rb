require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/district_repository'

class DistrictRepositoryTest < MiniTest::Test

  def test_loads_data
    assert_equal "ADAMS-ARAPAHOE 28J", @dr.district_objects[2].name
  end

  def setup
    @dr = DistrictRepository.new
    @dr.load_data({
  :enrollment => {
    :kindergarten => "./data/Kindergartners in full-day program.csv",
    :high_school_graduation => "./data/High school graduation rates.csv"
  },
  :statewide_testing => {
    :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
    :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
    :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
    :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
    :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
  },
  :economic_profile => {
   :median_household_income => "./data/Median household income.csv",
   :children_in_poverty => "./data/School-aged children in poverty.csv",
   :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
   :title_i => "./data/Title I students.csv"
   }
})
  end

  def test_find_by_name_method_returns_instantiated_object_name
    assert_equal "ADAMS-ARAPAHOE 28J", @dr.find_by_name("ADAMS-ARAPAHOE 28J").name
  end

  def test_find_by_name_is_not_case_insensitive
    assert_equal "ADAMS-ARAPAHOE 28J", @dr.find_by_name("Adams-Arapahoe 28J").name
  end

  def test_returns_nil_if_district_by_name_doesnt_exist
      assert_equal nil, @dr.find_by_name("Aldkfjalkd")
  end

  def test_find_all_matching
    assert_equal 2, @dr.find_all_matching("Adams").count
  end

  def test_relationship_with_enrollment_data
    district = @dr.find_by_name("ACADEMY 20")

    assert_equal 0.436, district.enrollment.kindergarten_participation_in_year(2010)
  end

  def test_relationship_with_statwide_testing_data
    district = @dr.find_by_name("ACADEMY 20")
    result = {2008=>{:math=>0.857, :reading=>0.866, :writing=>0.671},
              2009=>{:math=>0.824, :reading=>0.862, :writing=>0.706},
              2010=>{:math=>0.849, :reading=>0.864, :writing=>0.662},
              2011=>{:math=>0.819, :reading=>0.867, :writing=>0.678},
              2012=>{:reading=>0.87, :math=>0.83, :writing=>0.655},
              2013=>{:math=>0.855, :reading=>0.859, :writing=>0.669},
              2014=>{:math=>0.835, :reading=>0.831, :writing=>0.639}}
    assert_equal result, district.statewide_test.proficient_by_grade(3)
  end

  def test_relationship_with_economic_profile_data
    district = @dr.find_by_name("ACADEMY 20")

    assert_equal 0.012, district.economic_profile.title_i_in_year(2013)
  end
end
