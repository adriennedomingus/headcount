require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/enrollment_reposiory'

class EnrollmentRepositoryTest < MiniTest::Test

  def test_loads_data
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    result = {:name=>"ACADEMY 20", :kindergarten_participation=>{2010=>0.43628}}
    assert_equal result, er.enrollment_objects[17].data
  end

  def test_finds_enrollment_object_by_name
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    result = er.find_by_name("ADAMS-ARAPAHOE 28J")

    assert_equal true, result.include?(:kindergarten_participation)
    assert_equal "ADAMS-ARAPAHOE 28J", result[:name]
  end

  def test_finds_by_name_is_not_case_sensitive
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    result = er.find_by_name("Adams County 14")

    assert_equal true, result.include?(:kindergarten_participation)
    assert_equal "ADAMS COUNTY 14", result[:name]
  end
end
