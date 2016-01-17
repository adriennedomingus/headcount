require_relative '../lib/statewide_test_repository'
require 'minitest/autorun'
require 'minitest/pride'

class StatewideTestRepositoryTest < MiniTest::Test

  def test_loads_data
    str = StatewideTestRepository.new
    str.load_data({:statewide_testing => {
      :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
      :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
      :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
      :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
      :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"}})
    require "pry"
    binding.pry
    result = {:math=>0.6942, :writing=>0.69377, :reading=>0.81747}
    require "pry"
    binding.pry
    assert_equal result, str.statewide_objects[17].data[:eighth_grade][2012]
  end

  def test_finds_by_name
    str = StatewideTestRepository.new
    str.load_data({:statewide_testing => {
      :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
      :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
      :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
      :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
      :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"}})

    result = str.find_by_name("ADAMS-ARAPAHOE 28J")
    math_result = {:all_students=>0.37735, :asian=>0.4859, :black=>0.2916, :hawaiian_pacific_islander=>0.4438, :hispanic=>0.3356, :native_american=>0.4438, :two_or_more=>0.4452, :white=>0.5502}

    assert_equal true, result.data.include?(:third_grade)
    assert_equal "ADAMS-ARAPAHOE 28J", result.data[:name]
    assert_equal math_result, result.data[:math][2012]
  end

  def test_unknown_data_errors
    str = StatewideTestRepository.new
    str.load_data({:statewide_testing => {
      :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
      :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
      :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
      :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
      :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"}})
    testing = str.find_by_name("AULT-HIGHLAND RE-9")

    assert_raises(UnknownDataError) do
      testing.proficient_by_grade(1)
    end

    assert_raises(UnknownDataError) do
      testing.proficient_for_subject_by_grade_in_year(:chicken, 8, 2011)
    end

    assert_raises(UnknownDataError) do
      testing.proficient_for_subject_by_race_in_year(:reading, :chicken, 2013)
    end

    assert_raises(UnknownDataError) do
      testing.proficient_for_subject_by_race_in_year(:chicken, :white, 2013)
    end
  end
end
