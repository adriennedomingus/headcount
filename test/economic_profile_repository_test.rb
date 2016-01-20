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
    result = {:name=>"ARCHULETA COUNTY 50 JT",
              :median_household_income=>{[2005, 2009]=>57732, [2006, 2010]=>57633, [2008, 2012]=>54301, [2007, 2011]=>61028, [2009, 2013]=>48818},
              :children_in_poverty=>{1995=>0.146, 1997=>0.198, 1999=>0.169, 2000=>0.195, 2001=>0.179, 2002=>0.186, 2003=>0.162, 2004=>0.148, 2005=>0.181, 2006=>0.176, 2007=>0.166, 2008=>0.187, 2009=>0.227, 2010=>0.217, 2011=>0.241, 2012=>0.244, 2013=>0.239},
              :free_or_reduced_price_lunch=>{2000=>{:percentage=>0.36, :total=>554}, 2001=>{:total=>514, :percentage=>0.328}, 2002=>{:percentage=>0.331, :total=>526}, 2003=>{:total=>606, :percentage=>0.39}, 2004=>{:percentage=>0.398, :total=>628}, 2005=>{:total=>607, :percentage=>0.359}, 2006=>{:percentage=>0.416, :total=>703}, 2007=>{:total=>677, :percentage=>0.44}, 2008=>{:percentage=>0.462, :total=>704}, 2013=>{:total=>663, :percentage=>0.501}, 2009=>{:percentage=>0.506, :total=>768}, 2010=>{:total=>764, :percentage=>0.512}, 2011=>{:percentage=>0.518, :total=>728}, 2012=>{:total=>733, :percentage=>0.535}, 2014=>{:percentage=>0.524, :total=>695}},
              :title_i=>{2009=>0.504, 2011=>0.671, 2012=>0.693, 2013=>0.704, 2014=>0.715}}
    assert_equal result, @epr.economic_profile_objects[3].data
  end

  def test_it_can_find_by_name
    result = {:name=>"ACADEMY 20",
              :median_household_income=>{[2005, 2009]=>85060, [2006, 2010]=>85450, [2008, 2012]=>89615, [2007, 2011]=>88099, [2009, 2013]=>89953},
              :children_in_poverty=>{1995=>0.032, 1997=>0.035, 1999=>0.032, 2000=>0.031, 2001=>0.029, 2002=>0.033, 2003=>0.037, 2004=>0.034, 2005=>0.042, 2006=>0.036, 2007=>0.039, 2008=>0.044, 2009=>0.047, 2010=>0.058, 2011=>0.059, 2012=>0.064, 2013=>0.048},
              :free_or_reduced_price_lunch=>{2014=>{:total=>3132, :percentage=>0.127}, 2012=>{:percentage=>0.125, :total=>3006}, 2011=>{:total=>2834, :percentage=>0.12}, 2010=>{:percentage=>0.113, :total=>2601}, 2009=>{:total=>2338, :percentage=>0.103}, 2013=>{:percentage=>0.132, :total=>3225}, 2008=>{:total=>2058, :percentage=>0.094}, 2007=>{:percentage=>0.08, :total=>1630}, 2006=>{:total=>1534, :percentage=>0.072}, 2005=>{:percentage=>0.059, :total=>1204}, 2004=>{:total=>1182, :percentage=>0.06}, 2003=>{:percentage=>0.06, :total=>1062}, 2002=>{:total=>905, :percentage=>0.048}, 2001=>{:percentage=>0.047, :total=>855}, 2000=>{:total=>701, :percentage=>0.04}},
              :title_i=>{2009=>0.014, 2011=>0.011, 2012=>0.011, 2013=>0.012, 2014=>0.027}}
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

    assert_equal 0.012, district.title_i_in_year(2013)
  end
end
