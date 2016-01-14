require_relative '../lib/statewide_test_repository'
require 'minitest/autorun'
require 'minitest/pride'

class StatewideTestRepositoryTest < MiniTest::Test

  def test_loads_data
    skip
    str = StatewideTestRepository.new
    str.load_data({:statewide_testing => {
      :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
      :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
      :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
      :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
      :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"}})

    result = {:math=>0.6942, :writing=>0.69377, :reading=>0.81747}
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
    assert_equal true, result.data.include?(:third_grade)
    assert_equal "ADAMS-ARAPAHOE 28J", result.data[:name]
  end
end
