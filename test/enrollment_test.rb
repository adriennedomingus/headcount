require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/enrollment'

class EnrollmentTest < MiniTest::Test

  def test_it_has_a_name
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    assert_equal "ACADEMY 20", e.name
  end

  def test_returns_kindergarten_participation_by_year
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})

    result = {2010=>0.3915, 2011=>0.35356, 2012=>0.2677}
    assert_equal result, e.kindergarten_participation_by_year
  end

  def test_returns_kindergarten_participation_in_specific_year
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})

    assert_equal 0.3915, e.kindergarten_participation_in_year(2010)
  end

  def test_returns_nil_for_unknown_year
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})

    assert_equal nil, e.kindergarten_participation_in_year(1995)
  end

  def test_returns_graduation_rate_by_year
    e = Enrollment.new({:name=>"ADAMS-ARAPAHOE 28J",:kindergarten_participation=>{2007=>0.47359,2006=>0.37013,2005=>0.20176,2004=>0.17444,2008=>0.47965,2009=>0.73,2010=>0.92209,2011=>0.95,2012=>0.97359,2013=>0.9767,2014=>0.97123},:high_school_graduation=>{2010=>0.903, 2011=>0.891, 2012=>0.85455, 2013=>0.88333, 2014=>0.91}})

    result = {2010=>0.903, 2011=>0.891, 2012=>0.85455, 2013=>0.88333, 2014=>0.91}
    assert_equal result, e.graduation_rate_by_year
  end

  def test_returns_graduation_rate_in_specific_year
    e = Enrollment.new({:name=>"ADAMS-ARAPAHOE 28J",:kindergarten_participation=>{2007=>0.47359,2006=>0.37013,2005=>0.20176,2004=>0.17444,2008=>0.47965,2009=>0.73,2010=>0.92209,2011=>0.95,2012=>0.97359,2013=>0.9767,2014=>0.97123},:high_school_graduation=>{2010=>0.903, 2011=>0.891, 2012=>0.85455, 2013=>0.88333, 2014=>0.91}})

    result = 0.891
    assert_equal result, e.graduation_rate_in_year(2011)
  end

  #test for what happens when data doesn't exist for year

end
