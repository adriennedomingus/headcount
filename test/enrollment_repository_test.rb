require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/enrollment_repository'

class EnrollmentRepositoryTest < MiniTest::Test

  def test_loads_data
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv",
      :high_school_graduation => "./data/High school graduation rates.csv"}})
    result = {:name=>"BOULDER VALLEY RE 2",
              :kindergarten_participation=>{2007=>0.067, 2006=>0.032, 2005=>0.033, 2004=>0.016, 2008=>0.118, 2009=>0.1, 2010=>0.157, 2011=>0.248, 2012=>0.23, 2013=>0.0, 2014=>0.279},
              :high_school_graduation=>{2010=>0.847, 2011=>0.883, 2012=>0.897, 2013=>0.909, 2014=>0.918}}
    assert_equal result, @er.enrollment_objects[7].data
  end

  def setup
    @er = EnrollmentRepository.new
    @er.load_data({:enrollment =>
      {:kindergarten => "./data/Kindergartners in full-day program.csv",
        :high_school_graduation => "./data/High school graduation rates.csv"}})
  end

  def test_finds_enrollment_object_by_name
    result = {:name=>"ADAMS COUNTY 14",
              :kindergarten_participation=>{2007=>0.306, 2006=>0.293, 2005=>0.3, 2004=>0.228, 2008=>0.673, 2009=>1.0, 2010=>1.0, 2011=>1.0, 2012=>1.0, 2013=>0.998, 2014=>1.0},
              :high_school_graduation=>{2010=>0.57, 2011=>0.608, 2012=>0.634, 2013=>0.594, 2014=>0.659}}
  end

  def test_case_insensitive_find_by_name_with_two_files
    result = {:name=>"ACADEMY 20",
              :kindergarten_participation=>{2007=>0.392, 2006=>0.354, 2005=>0.267, 2004=>0.302, 2008=>0.385, 2009=>0.39, 2010=>0.436, 2011=>0.489, 2012=>0.479, 2013=>0.488, 2014=>0.49},
              :high_school_graduation=>{2010=>0.895, 2011=>0.895, 2012=>0.89, 2013=>0.914, 2014=>0.898}}
    assert_equal result, @er.find_by_name("aCadeMy 20").data
  end

  def test_can_find_graduation_rate_by_year_after_find_by_name
    result = {2010=>0.57, 2011=>0.608, 2012=>0.634, 2013=>0.594, 2014=>0.659}

    enrollment = @er.find_by_name("ADAMS COUNTY 14")
    assert_equal result, enrollment.graduation_rate_by_year
  end

  def test_can_find_graduation_rate_in_year_after_find_by_name
    result = 0.608
    enrollment = @er.find_by_name("ADAMS COUNTY 14")
    assert_equal result, enrollment.graduation_rate_in_year(2011)
  end
end
