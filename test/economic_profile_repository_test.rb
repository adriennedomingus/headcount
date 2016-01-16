require_relative '../lib/economic_profile_repository'
require 'minitest/autorun'
require 'minitest/pride'

class EconomicProfileRepositoryTest < Minitest::Test
  def setup
    @epr = EconomicProfileRepository.new
    @epr.load_data({
                   :economic_profile => {
                   :median_household_income => "./data/Median household income.csv",
                   :children_in_poverty => "./data/School-aged children in poverty.csv",
                   :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
                   :title_i => "./data/Title I students.csv"}
                   })
  end

  def test_it_loads_data
    skip
    result = {:name=>"ADAMS-ARAPAHOE 28J", :median_household_income=>{[2005, 2009]=>43893.0, [2006, 2010]=>44007.0, [2008, 2012]=>45438.0, [2007, 2011]=>44687.0, [2009, 2013]=>45507.0}, :children_in_poverty=>{:percent=>{1995=>0.119, 1997=>0.143, 1999=>0.151, 2000=>0.146, 2001=>0.141, 2002=>0.161, 2003=>0.18, 2004=>0.182, 2005=>0.181, 2006=>0.208, 2007=>0.238, 2008=>0.18582, 2009=>0.234, 2010=>0.23357, 2011=>0.26, 2012=>0.268, 2013=>0.267}, :number=>{2008=>6983, 2009=>9084, 2010=>9251, 2011=>10363, 2012=>10828, 2013=>10934}}, :free_or_reduced_price_lunch=>{:percent=>{2014=>0.69422, 2012=>0.67797, 2011=>0.6501, 2010=>0.635, 2009=>0.6134, 2013=>0.67657, 2008=>0.5959, 2007=>0.56, 2006=>0.5394, 2005=>0.4935, 2004=>0.4826, 2003=>0.42, 2002=>0.42164, 2001=>0.35603, 2000=>0.36}, :number=>{2014=>28969, 2012=>27007, 2011=>25808, 2010=>24513, 2009=>22677, 2013=>27656, 2008=>21167, 2007=>18792, 2006=>18247, 2005=>16434, 2004=>15563, 2003=>13715, 2002=>13599, 2001=>11225, 2000=>10987}}, :title_i=>{2009=>0.315, 2011=>0.352, 2012=>0.3576, 2013=>0.35509, 2014=>0.35278}}

    assert_equal result, @epr.economic_profile_objects[3].data
  end

  def test_it_can_find_by_name
    skip
    result = {:name=>"ACADEMY 20", :median_household_income=>{[2005, 2009]=>85060, [2006, 2010]=>85450, [2008, 2012]=>89615, [2007, 2011]=>88099, [2009, 2013]=>89953}, :children_in_poverty=>{:percent=>{1995=>0.032, 1997=>0.035, 1999=>0.032, 2000=>0.031, 2001=>0.029, 2002=>0.033, 2003=>0.037, 2004=>0.034, 2005=>0.042, 2006=>0.036, 2007=>0.039, 2008=>0.04404, 2009=>0.047, 2010=>0.05754, 2011=>0.059, 2012=>0.064, 2013=>0.048}, :number=>{2008=>855, 2009=>921, 2010=>1251, 2011=>1279, 2012=>1401, 2013=>1067}}, :free_or_reduced_price_lunch=>{:percent=>{2014=>0.12743, 2012=>0.12539, 2011=>0.1198, 2010=>0.113, 2009=>0.1034, 2013=>0.13173, 2008=>0.0939, 2007=>0.08, 2006=>0.0723, 2005=>0.0587, 2004=>0.0596, 2003=>0.06, 2002=>0.0484, 2001=>0.04714, 2000=>0.04}, :number=>{2014=>3132, 2012=>3006, 2011=>2834, 2010=>2601, 2009=>2338, 2013=>3225, 2008=>2058, 2007=>1630, 2006=>1534, 2005=>1204, 2004=>1182, 2003=>1062, 2002=>905, 2001=>855, 2000=>701}}, :title_i=>{2009=>0.014, 2011=>0.011, 2012=>0.01072, 2013=>0.01246, 2014=>0.0273}}

    assert_equal result, @epr.find_by_name("ACADEMY 20").data
  end

  def test_it_finds_median_household_income_in_specific_year
    district = @epr.find_by_name("ACADEMY 20")

    assert_equal 88279.25, district.median_household_income_in_year(2010)
  end

  def test_it_finds_average_of_median_household_incomes
    district = @epr.find_by_name("ACADEMY 20")

    assert_equal 87635.4, district.median_household_income_average
  end

  def test_it_finds_the_percentage_of_children_in_poverty_in_year
    district = @epr.find_by_name("ACADEMY 20")

    assert_equal 0.064, district.children_in_poverty_in_year(2012)
  end

  def test_finds_percentage_of_frl_eligible_students_in_year
    district = @epr.find_by_name("ACADEMY 20")

    assert_equal 0.113, district.free_or_reduced_price_lunch_percentage_in_year(2010)
  end

  def test_finds_number_of_frl_eligible_students_in_year
    district = @epr.find_by_name("ACADEMY 20")

    assert_equal 3225, district.free_or_reduced_price_lunch_number_in_year(2013)
  end

  def test_finds_percent_of_title_i_eligible_students_in_year
    district = @epr.find_by_name("ACADEMY 20")

    assert_equal 0.01246, district.title_i_in_year(2013)
  end
end
