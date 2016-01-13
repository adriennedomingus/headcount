require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/enrollment_repository'

class EnrollmentRepositoryTest < MiniTest::Test

  def test_loads_data
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    result = {:name=>"ACADEMY 20", :kindergarten_participation=>{2010=>0.43628}}
    assert_equal result, er.enrollment_objects[17].data
  end

  def test_loads_two_data_files
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv", :high_school_graduation => "./data/High school graduation rates.csv"}})

    result = {:name=>"ACADEMY 20", :kindergarten_participation=>{2010=>0.43628}, :high_school_graduation=>{2010=>0.903}}
    assert_equal result, er.enrollment_objects[17].data
  end

  def test_finds_enrollment_object_by_name
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    result = er.find_by_name("ADAMS-ARAPAHOE 28J")

    assert_equal true, result.data.include?(:kindergarten_participation)
    assert_equal "ADAMS-ARAPAHOE 28J", result.data[:name]
  end

  def test_find_by_name_with_two_files
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv", :high_school_graduation => "./data/High school graduation rates.csv"}})

    result = {:name=>"ADAMS-ARAPAHOE 28J",:kindergarten_participation=>{2007=>0.47359,2006=>0.37013,2005=>0.20176,2004=>0.17444,2008=>0.47965,2009=>0.73,2010=>0.92209,2011=>0.95,2012=>0.97359,2013=>0.9767,2014=>0.97123},:high_school_graduation=>{2010=>0.903, 2011=>0.891, 2012=>0.85455, 2013=>0.88333, 2014=>0.91}}
    assert_equal result, er.find_by_name("ADAMS-ARAPAHOE 28J").data
  end

  def test_case_insensitive_find_by_name_with_two_files
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv", :high_school_graduation => "./data/High school graduation rates.csv"}})

    result = {:name=>"ACADEMY 20", :kindergarten_participation=>{2007=>0.39159, 2006=>0.35364, 2005=>0.26709, 2004=>0.30201, 2008=>0.38456, 2009=>0.39, 2010=>0.43628, 2011=>0.489, 2012=>0.47883, 2013=>0.48774, 2014=>0.49022}, :high_school_graduation=>{2010=>0.903, 2011=>0.891, 2012=>0.85455, 2013=>0.88333, 2014=>0.91}}
    assert_equal result, er.find_by_name("aCadeMy 20").data
  end

  def test_finds_by_name_is_not_case_sensitive
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    result = er.find_by_name("Adams County 14")

    assert_equal true, result.data.include?(:kindergarten_participation)
    assert_equal "ADAMS COUNTY 14", result.data[:name]
  end

  def test_can_find_graduation_rate_by_year_after_find_by_name
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv", :high_school_graduation => "./data/High school graduation rates.csv"}})
    result = {2010=>0.903, 2011=>0.891, 2012=>0.85455, 2013=>0.88333, 2014=>0.91}

    enrollment = er.find_by_name("ADAMS COUNTY 14")
    assert_equal result, enrollment.graduation_rate_by_year
  end
end
