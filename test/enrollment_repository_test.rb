require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/enrollment_repository'

class EnrollmentRepositoryTest < MiniTest::Test

  def test_loads_data
    skip
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv", :high_school_graduation => "./data/High school graduation rates.csv"}})
    result = {:name=>"BOULDER VALLEY RE 2", :kindergarten_participation=>{2007=>0.06657, 2006=>0.03188, 2005=>0.03332, 2004=>0.01616, 2008=>0.1181, 2009=>0.1, 2010=>0.15748, 2011=>0.248, 2012=>0.22955, 2013=>0.0, 2014=>0.2789}, :high_school_graduation=>{2010=>0.847, 2011=>0.883, 2012=>0.89717, 2013=>0.90917, 2014=>0.918}}
    assert_equal result, @er.enrollment_objects[17].data
  end

  def setup
    @er = EnrollmentRepository.new
    @er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv", :high_school_graduation => "./data/High school graduation rates.csv"}})
  end

  def test_finds_enrollment_object_by_name
    result = {:name=>"ADAMS COUNTY 14", :kindergarten_participation=>{2007=>0.30643, 2006=>0.29331, 2005=>0.3, 2004=>0.22797, 2008=>0.67331, 2009=>1.0, 2010=>1.0, 2011=>1.0, 2012=>1.0, 2013=>0.9983, 2014=>1.0}, :high_school_graduation=>{2010=>0.57, 2011=>0.608, 2012=>0.63372, 2013=>0.59351, 2014=>0.659}}
    assert_equal result, @er.find_by_name("ADAMS COUNTY 14").data
  end

  def test_case_insensitive_find_by_name_with_two_files
    result = {:name=>"ACADEMY 20", :kindergarten_participation=>{2007=>0.39159, 2006=>0.35364, 2005=>0.26709, 2004=>0.30201, 2008=>0.38456, 2009=>0.39, 2010=>0.43628, 2011=>0.489, 2012=>0.47883, 2013=>0.48774, 2014=>0.49022}, :high_school_graduation=>{2010=>0.895, 2011=>0.895, 2012=>0.88983, 2013=>0.91373, 2014=>0.898}}
    assert_equal result, @er.find_by_name("aCadeMy 20").data
  end

  def test_can_find_graduation_rate_by_year_after_find_by_name
    result = {2010=>0.57, 2011=>0.608, 2012=>0.63372, 2013=>0.59351, 2014=>0.659}

    enrollment = @er.find_by_name("ADAMS COUNTY 14")
    assert_equal result, enrollment.graduation_rate_by_year
  end

  def test_can_find_graduation_rate_in_year_after_find_by_name
    result = 0.608
    enrollment = @er.find_by_name("ADAMS COUNTY 14")
    assert_equal result, enrollment.graduation_rate_in_year(2011)
  end
end
