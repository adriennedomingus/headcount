require_relative '../lib/statewide_test'
require 'minitest/autorun'
require 'minitest/pride'

class StatewideTestTest < Minitest::Test

  def test_has_a_name
    s = StatewideTest.new({:name=>"ADAMS-ARAPAHOE 28J"})
    assert_equal "ADAMS-ARAPAHOE 28J", s.name
  end

  def test_proficient_by_grade
    s = StatewideTest.new({
      :name=>"ADAMS-ARAPAHOE 28J",
      :third_grade=>{2009=>{:math=>0.456, :reading=>0.483, :writing=>0.359},
        2010=>{:math=>0.453, :reading=>0.458, :writing=>0.286},
        2008=>{:reading=>0.466, :writing=>0.339},
        2011=>{:math=>0.429, :reading=>0.49, :writing=>0.286},
        2012=>{:reading=>0.515, :math=>0.471, :writing=>0.34919},
        2013=>{:math=>0.48704, :reading=>0.48781, :writing=>0.3037},
        2014=>{:math=>0.49919, :reading=>0.46357, :writing=>0.32814}},
      :eighth_grade=>{2008=>{:math=>0.32, :reading=>0.456, :writing=>0.265},
        2009=>{:math=>0.338, :reading=>0.437, :writing=>0.302},
        2010=>{:math=>0.369, :reading=>0.496, :writing=>0.326},
        2011=>{:reading=>0.47932, :math=>0.34556, :writing=>0.30448},
        2012=>{:math=>0.33157, :writing=>0.33876, :reading=>0.4401},
        2013=>{:math=>0.32687, :reading=>0.47095, :writing=>0.39721},
        2014=>{:math=>0.28971, :reading=>0.404, :writing=>0.35091}}})

    third_result = {2009=>{:math=>0.456, :reading=>0.483, :writing=>0.359},
      2010=>{:math=>0.453, :reading=>0.458, :writing=>0.286},
      2008=>{:reading=>0.466, :writing=>0.339},
      2011=>{:math=>0.429, :reading=>0.49, :writing=>0.286},
      2012=>{:reading=>0.515, :math=>0.471, :writing=>0.34919},
      2013=>{:math=>0.48704, :reading=>0.48781, :writing=>0.3037},
      2014=>{:math=>0.49919, :reading=>0.46357, :writing=>0.32814}}

    eighth_result = {2008=>{:math=>0.32, :reading=>0.456, :writing=>0.265},
      2009=>{:math=>0.338, :reading=>0.437, :writing=>0.302},
      2010=>{:math=>0.369, :reading=>0.496, :writing=>0.326},
      2011=>{:reading=>0.47932, :math=>0.34556, :writing=>0.30448},
      2012=>{:math=>0.33157, :writing=>0.33876, :reading=>0.4401},
      2013=>{:math=>0.32687, :reading=>0.47095, :writing=>0.39721},
      2014=>{:math=>0.28971, :reading=>0.404, :writing=>0.35091}}

    assert_equal third_result, s.proficient_by_grade(3)
    assert_equal eighth_result, s.proficient_by_grade(8)
    #make edge case for if they offer a grade level that's not 3 or 8 UNKNOWNDATAERROR
  end

  def test_proficiency_by_race_or_ethnicity
    s = StatewideTest.new(:math=>{2011=>{:all_students=>0.68, :asian=>0.8169, :black=>0.4246, :hawaiian_pacific_islander=>0.5686, :hispanic=>0.5681, :native_american=>0.6143, :two_or_more=>0.6772, :white=>0.7065}, 2012=>{:all_students=>0.6894, :asian=>0.8182, :black=>0.4248, :hawaiian_pacific_islander=>0.5714, :hispanic=>0.5722, :native_american=>0.5714, :two_or_more=>0.6899, :white=>0.7135}, 2013=>{:all_students=>0.69683, :asian=>0.8053, :black=>0.4404, :hawaiian_pacific_islander=>0.6833, :hispanic=>0.5883, :native_american=>0.5932, :two_or_more=>0.6967, :white=>0.7208}, 2014=>{:all_students=>0.69944, :asian=>0.8, :black=>0.4205, :hawaiian_pacific_islander=>0.6818, :hispanic=>0.6048, :native_american=>0.5439, :two_or_more=>0.6932, :white=>0.723}}, :reading=>{2011=>{:all_students=>0.83, :asian=>0.8976, :black=>0.662, :hawaiian_pacific_islander=>0.7451, :hispanic=>0.7486, :native_american=>0.8169, :two_or_more=>0.8419, :white=>0.8513}, 2012=>{:all_students=>0.84585, :asian=>0.89328, :black=>0.69469, :hawaiian_pacific_islander=>0.83333, :hispanic=>0.77167, :native_american=>0.78571, :two_or_more=>0.84584, :white=>0.86189}, 2013=>{:all_students=>0.84505, :asian=>0.90193, :black=>0.66951, :hawaiian_pacific_islander=>0.86667, :hispanic=>0.77278, :native_american=>0.81356, :two_or_more=>0.85582, :white=>0.86083}, 2014=>{:all_students=>0.84127, :asian=>0.85531, :black=>0.70387, :hawaiian_pacific_islander=>0.93182, :hispanic=>0.00778, :native_american=>0.00724, :two_or_more=>0.00859, :white=>0.00856}}, :writing=>{2011=>{:all_students=>0.7192, :asian=>0.8268, :black=>0.5152, :hawaiian_pacific_islander=>0.7255, :hispanic=>0.6068, :native_american=>0.6, :two_or_more=>0.7274, :white=>0.7401}, 2012=>{:all_students=>0.70593, :asian=>0.8083, :black=>0.5044, :hawaiian_pacific_islander=>0.6833, :hispanic=>0.5978, :native_american=>0.5893, :two_or_more=>0.7186, :white=>0.7262}, 2013=>{:all_students=>0.72029, :asian=>0.8109, :black=>0.4819, :hawaiian_pacific_islander=>0.7167, :hispanic=>0.623, :native_american=>0.6102, :two_or_more=>0.7474, :white=>0.7406}, 2014=>{:all_students=>0.71583, :asian=>0.7894, :black=>0.5194, :hawaiian_pacific_islander=>0.7273, :hispanic=>0.6244, :native_american=>0.6207, :two_or_more=>0.7317, :white=>0.7348}})
    result1 = {2011=>{:math=>0.8169, :reading=>0.8976, :writing=>0.8268}, 2012=>{:math=>0.8182, :reading=>0.89328, :writing=>0.8083}, 2013=>{:math=>0.8053, :reading=>0.90193, :writing=>0.8109}, 2014=>{:math=>0.8, :reading=>0.85531, :writing=>0.7894}}
    result2 = {2011=>{:math=>0.68, :reading=>0.83, :writing=>0.7192}, 2012=>{:math=>0.6894, :reading=>0.84585, :writing=>0.70593}, 2013=>{:math=>0.69683, :reading=>0.84505, :writing=>0.72029}, 2014=>{:math=>0.69944, :reading=>0.84127, :writing=>0.71583}}

    assert_equal result1, s.proficient_by_race_or_ethnicity(:asian)
    assert_equal result2, s.proficient_by_race_or_ethnicity(:all_students)
    #UNKNOWNRACE ERROR
  end

  def test_proficient_for_subject_by_grade_in_year
    s = StatewideTest.new({
      :name=>"ADAMS-ARAPAHOE 28J",
      :third_grade=>{2009=>{:math=>0.456, :reading=>0.483, :writing=>0.359},
        2010=>{:math=>0.453, :reading=>0.458, :writing=>0.286},
        2008=>{:reading=>0.466, :writing=>0.339},
        2011=>{:math=>0.429, :reading=>0.49, :writing=>0.286},
        2012=>{:reading=>0.515, :math=>0.471, :writing=>0.34919},
        2013=>{:math=>0.48704, :reading=>0.48781, :writing=>0.3037},
        2014=>{:math=>0.49919, :reading=>0.46357, :writing=>0.32814}},
      :eighth_grade=>{2008=>{:math=>0.32, :reading=>0.456, :writing=>0.265},
        2009=>{:math=>0.338, :reading=>0.437, :writing=>0.302},
        2010=>{:math=>0.369, :reading=>0.496, :writing=>0.326},
        2011=>{:reading=>0.47932, :math=>0.34556, :writing=>0.30448},
        2012=>{:math=>0.33157, :writing=>0.33876, :reading=>0.4401},
        2013=>{:math=>0.32687, :reading=>0.47095, :writing=>0.39721},
        2014=>{:math=>0.28971, :reading=>0.404, :writing=>0.35091}}})

    assert_equal 0.429, s.proficient_for_subject_by_grade_in_year(:math, 3, 2011)
    assert_equal 0.47932, s.proficient_for_subject_by_grade_in_year(:reading, 8, 2011)
    #add test for UNKNOWNDATAERROR
  end

  def test_proficient_for_subject_by_race_in_year
    s = StatewideTest.new(:math=>{2011=>{:all_students=>0.68, :asian=>0.8169, :black=>0.4246, :hawaiian_pacific_islander=>0.5686, :hispanic=>0.5681, :native_american=>0.6143, :two_or_more=>0.6772, :white=>0.7065}, 2012=>{:all_students=>0.6894, :asian=>0.8182, :black=>0.4248, :hawaiian_pacific_islander=>0.5714, :hispanic=>0.5722, :native_american=>0.5714, :two_or_more=>0.6899, :white=>0.7135}, 2013=>{:all_students=>0.69683, :asian=>0.8053, :black=>0.4404, :hawaiian_pacific_islander=>0.6833, :hispanic=>0.5883, :native_american=>0.5932, :two_or_more=>0.6967, :white=>0.7208}, 2014=>{:all_students=>0.69944, :asian=>0.8, :black=>0.4205, :hawaiian_pacific_islander=>0.6818, :hispanic=>0.6048, :native_american=>0.5439, :two_or_more=>0.6932, :white=>0.723}}, :reading=>{2011=>{:all_students=>0.83, :asian=>0.8976, :black=>0.662, :hawaiian_pacific_islander=>0.7451, :hispanic=>0.7486, :native_american=>0.8169, :two_or_more=>0.8419, :white=>0.8513}, 2012=>{:all_students=>0.84585, :asian=>0.89328, :black=>0.69469, :hawaiian_pacific_islander=>0.83333, :hispanic=>0.77167, :native_american=>0.78571, :two_or_more=>0.84584, :white=>0.86189}, 2013=>{:all_students=>0.84505, :asian=>0.90193, :black=>0.66951, :hawaiian_pacific_islander=>0.86667, :hispanic=>0.77278, :native_american=>0.81356, :two_or_more=>0.85582, :white=>0.86083}, 2014=>{:all_students=>0.84127, :asian=>0.85531, :black=>0.70387, :hawaiian_pacific_islander=>0.93182, :hispanic=>0.00778, :native_american=>0.00724, :two_or_more=>0.00859, :white=>0.00856}}, :writing=>{2011=>{:all_students=>0.7192, :asian=>0.8268, :black=>0.5152, :hawaiian_pacific_islander=>0.7255, :hispanic=>0.6068, :native_american=>0.6, :two_or_more=>0.7274, :white=>0.7401}, 2012=>{:all_students=>0.70593, :asian=>0.8083, :black=>0.5044, :hawaiian_pacific_islander=>0.6833, :hispanic=>0.5978, :native_american=>0.5893, :two_or_more=>0.7186, :white=>0.7262}, 2013=>{:all_students=>0.72029, :asian=>0.8109, :black=>0.4819, :hawaiian_pacific_islander=>0.7167, :hispanic=>0.623, :native_american=>0.6102, :two_or_more=>0.7474, :white=>0.7406}, 2014=>{:all_students=>0.71583, :asian=>0.7894, :black=>0.5194, :hawaiian_pacific_islander=>0.7273, :hispanic=>0.6244, :native_american=>0.6207, :two_or_more=>0.7317, :white=>0.7348}})

    result1 = 0.8182
    result2 = 0.72029
    assert_equal result1, s.proficient_for_subject_by_race_in_year(:math, :asian, 2012)
    assert_equal result2, s.proficient_for_subject_by_race_in_year(:writing, :all_students, 2013)
  end

end
