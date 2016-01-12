require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/district_repository'

class DistrictRepositoryTest < MiniTest::Test

  def test_loads_data
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})

    assert_equal "ADAMS COUNTY 14", dr.district_objects[2].name
  end

  def test_find_by_name_method_returns_instantiated_object_name
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    assert_equal "ADAMS-ARAPAHOE 28J", dr.find_by_name("ADAMS-ARAPAHOE 28J").name
  end

  def test_find_by_name_is_not_case_insensitive
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})

    assert_equal "ADAMS-ARAPAHOE 28J", dr.find_by_name("Adams-Arapahoe 28J").name
  end

  def test_find_all_matching
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    matching_names = []
    dr.find_all_matching("Adams").each do |district|
      matching_names << district.name
    end

    assert_equal ["ADAMS COUNTY 14", "ADAMS-ARAPAHOE 28J"], matching_names
  end

  # def test_starting_relationships_layer
  #   dr = DistrictRepository.new
  #   dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
  #   district = dr.find_by_name("ACADEMY 20")
  #   assert_equal 0.391, district.enrollment.kindergarten_participation_in_year(2010)
  # end
end
