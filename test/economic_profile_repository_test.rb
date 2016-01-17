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
    result = {:name=>"ADAMS-ARAPAHOE 28J",
              :median_household_income=>{[2005, 2009]=>43893, [2006, 2010]=>44007, [2008, 2012]=>45438, [2007, 2011]=>44687, [2009, 2013]=>45507},
              :children_in_poverty=>{1995=>0.119, 1997=>0.143, 1999=>0.151, 2000=>0.146, 2001=>0.141, 2002=>0.161, 2003=>0.18, 2004=>0.182, 2005=>0.181, 2006=>0.208, 2007=>0.238, 2008=>0.18582, 2009=>0.234, 2010=>0.23357, 2011=>0.26, 2012=>0.268, 2013=>0.267},
              :free_or_reduced_price_lunch=>{2014=>{:total=>28969, :percentage=>0.69422}, 2012=>{:percentage=>0.67797, :total=>27007}, 2011=>{:total=>25808, :percentage=>0.6501}, 2010=>{:percentage=>0.635, :total=>24513}, 2009=>{:total=>22677, :percentage=>0.6134}, 2013=>{:percentage=>0.67657, :total=>27656}, 2008=>{:total=>21167, :percentage=>0.5959}, 2007=>{:percentage=>0.56, :total=>18792}, 2006=>{:total=>18247, :percentage=>0.5394}, 2005=>{:percentage=>0.4935, :total=>16434}, 2004=>{:total=>15563, :percentage=>0.4826}, 2003=>{:percentage=>0.42, :total=>13715}, 2002=>{:total=>13599, :percentage=>0.42164}, 2001=>{:percentage=>0.35603, :total=>11225}, 2000=>{:total=>10987, :percentage=>0.36}}, :title_i=>{2009=>0.315, 2011=>0.352, 2012=>0.3576, 2013=>0.35509, 2014=>0.35278}}

    assert_equal result, @epr.economic_profile_objects[3].data
  end

  def test_it_can_find_by_name
    result = {:name=>"ACADEMY 20",
              :median_household_income=>{[2005, 2009]=>85060, [2006, 2010]=>85450, [2008, 2012]=>89615, [2007, 2011]=>88099, [2009, 2013]=>89953},
              :children_in_poverty=>{1995=>0.032, 1997=>0.035, 1999=>0.032, 2000=>0.031, 2001=>0.029, 2002=>0.033, 2003=>0.037, 2004=>0.034, 2005=>0.042, 2006=>0.036, 2007=>0.039, 2008=>855.0, 2009=>0.047, 2010=>0.05754, 2011=>0.059, 2012=>0.064, 2013=>0.048},
              :free_or_reduced_price_lunch=>{2014=>{:total=>3132, :percentage=>0.12743}, 2012=>{:percentage=>0.12539, :total=>3006}, 2011=>{:total=>2834, :percentage=>0.1198}, 2010=>{:percentage=>0.113, :total=>2601}, 2009=>{:total=>2338, :percentage=>0.1034}, 2013=>{:percentage=>0.13173, :total=>3225}, 2008=>{:total=>2058, :percentage=>0.0939}, 2007=>{:percentage=>0.08, :total=>1630}, 2006=>{:total=>1534, :percentage=>0.0723}, 2005=>{:percentage=>0.0587, :total=>1204}, 2004=>{:total=>1182, :percentage=>0.0596}, 2003=>{:percentage=>0.06, :total=>1062}, 2002=>{:total=>905, :percentage=>0.0484}, 2001=>{:percentage=>0.04714, :total=>855}, 2000=>{:total=>701, :percentage=>0.04}}, :title_i=>{2009=>0.014, 2011=>0.011, 2012=>0.01072, 2013=>0.01246, 2014=>0.0273}}

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
