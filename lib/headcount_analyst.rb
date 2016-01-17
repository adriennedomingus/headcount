require_relative 'district_repository'
require_relative 'result_set'

class HeadcountAnalyst

  attr_reader :dr, :district1, :district2

  def initialize(district_respository)
    @dr = district_respository
    @dr.load_data({
                  :enrollment => {
                    :kindergarten => "./data/Kindergartners in full-day program.csv",
                    :high_school_graduation => "./data/High school graduation rates.csv"
                  },
                  :economic_profile => {
                   :median_household_income => "./data/Median household income.csv",
                   :children_in_poverty => "./data/School-aged children in poverty.csv",
                   :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
                   :title_i => "./data/Title I students.csv"
                   }
                })
  end

  def kindergarten_participation_rate_variation(district1_name, district2_name)
    @district1 = @dr.find_by_name(district1_name)
    @district2 = @dr.find_by_name(district2_name[:against])
    district1_average = calculate_kindergarten_average(@district1)
    district2_average = calculate_kindergarten_average(@district2)
    variation = district1_average / district2_average
    truncate_value(variation)
  end

  def calculate_kindergarten_average(district)
    total = district.enrollment.data[:kindergarten_participation].values.reduce do |sum, participation|
       sum + truncate_value(participation)
    end
    average = total/district.enrollment.data[:kindergarten_participation].length
  average
  end

  def graduation_variation(district_name)
    district = dr.find_by_name(district_name)
    state = dr.find_by_name("COLORADO")
    calculate_graduation_average(district) / calculate_graduation_average(state)
  end

  def calculate_graduation_average(district)
    total = district.enrollment.data[:high_school_graduation].values.reduce do |sum, participation|
       sum + participation
    end
    average = total / district.enrollment.data[:high_school_graduation].length
    average
  end

  def kindergarten_variation(district)
    kindergarten_participation_rate_variation(district, :against => "COLORADO")
  end

  def kindergarten_participation_rate_variation_trend(district1, district2)
    result = Hash.new
    district1_participation = @dr.find_by_name(district1).enrollment.data[:kindergarten_participation]
    district2_participation = @dr.find_by_name(district2[:against]).enrollment.data[:kindergarten_participation]
    district1_participation.each do |key, value|
      d1_truncated_value = truncate_value(value)
      d2_truncated_value = truncate_value(district2_participation[key])
      result[key] = truncate_value(d1_truncated_value/d2_truncated_value)
    end
    result
  end

  def kindergarten_participation_against_high_school_graduation(district_name)
    result = kindergarten_variation(district_name) / graduation_variation(district_name)
    result
  end

  def kindergarten_participation_correlates_with_high_school_graduation(district)
    if district.keys == [:across]
      aggregated = district[:across].map do |district_name|
        kindergarten_graduation_correlation(district_name)
      end
      aggregated.count(true)/aggregated.length > 0.7 ? true : false
    elsif district[:for] != "STATEWIDE"
      kindergarten_graduation_correlation(district[:for])
    elsif district[:for] == "STATEWIDE"
      statewide_aggregated = []
      @dr.district_objects.each do |district_object|
        statewide_aggregated << kindergarten_graduation_correlation(district_object.name)
      end
      statewide_aggregated.count(true)/statewide_aggregated.length > 0.7 ? true : false
    end
  end

  def kindergarten_graduation_correlation(district)
    variation = kindergarten_participation_against_high_school_graduation(district)
    variation > 0.6 && variation < 1.5 ? true : false
  end

  def calculate_average_frl_number(district)
    @total = 0
    district.economic_profile.data[:free_or_reduced_price_lunch].each do |year|
      @total += year[1][:percentage]
    end
    average = truncate_value(@total)/district.economic_profile.data[:free_or_reduced_price_lunch].length
    truncate_value(average)
  end

  def calculate_avarage_percent_of_children_in_poverty(district)
    total = district.economic_profile.data[:children_in_poverty].values.reduce do |sum, participation|
       sum + participation
    end
    total/district.economic_profile.data[:children_in_poverty].length
  end

  def high_poverty_and_high_school_graduation
    state = @dr.find_by_name("COLORADO")
    rs = ResultSet.new(:matching_districts => [], :statewide_average => [])
    rs.statewide_average << ResultEntry.new({:free_and_reduced_price_lunch_rate => calculate_average_frl_number(state),
                                            #:children_in_poverty_rate => calculate_avarage_percent_of_children_in_poverty(state),
                                            :high_school_graduation_rate => calculate_graduation_average(state)})
    @dr.district_objects.each do |district_object|
      if calculate_average_frl_number(district_object) > calculate_average_frl_number(state) && calculate_graduation_average(district_object) > calculate_graduation_average(state) #&& calculate_avarage_percent_of_children_in_poverty(district_object) > calculate_avarage_percent_of_children_in_poverty(state)
        rs.matching_districts << ResultEntry.new({:free_and_reduced_price_lunch_rate => calculate_average_frl_number(district_object),
                                                #:children_in_poverty_rate => calculate_avarage_percent_of_children_in_poverty(district_object),
                                              :high_school_graduation_rate => calculate_graduation_average(district_object)})
      end
    end
    rs
  end

  def high_income_disparity
    state = @dr.find_by_name("COLORADO")
    rs = ResultSet.new(:matching_districts => [], :statewide_average => [])
    rs.statewide_average << ResultEntry.new({:median_household_income => calculate_average_of_median_household_income(state),
                                            #:children_in_poverty_rate => calculate_avarage_percent_of_children_in_poverty(state)
                                            })
    @dr.district_objects.each do |district_object|
      if  calculate_average_of_median_household_income(district_object) > calculate_average_of_median_household_income(state) #&& calculate_avarage_percent_of_children_in_poverty(district_object) > calculate_avarage_percent_of_children_in_poverty(state)
        rs.matching_districts << ResultEntry.new({:median_household_income => calculate_average_of_median_household_income(district_object),
                                                #:children_in_poverty_rate => calculate_avarage_percent_of_children_in_poverty(district_object)
                                                })
      end
    end
    require "pry"
    binding.pry
    rs
  end

  #DO WE NEED TO BE ABLE TO COMPARE THIS ACROSS DISTRICTS, OR JUST THE STATE?
  #IF YES TO THE ABOVE, DO WE NEED TO CALL IT WITH THE :against => "Colorado" FORMAT LIKE WITH KINDER
  def median_household_income_variation(district_name)
    district = @dr.find_by_name(district_name)
    state = @dr.find_by_name("COLORADO")
    calculate_average_of_median_household_income(district)/calculate_average_of_median_household_income(state)
  end

  def kindergarten_participation_against_household_income(district_name_symbol)
    kindergarten_participation_rate_variation(district_name_symbol, :against => "COLORADO") / median_household_income_variation(district_name_symbol)
  end

  def true_or_false_kindergarten_correlates_with_income(district_name_symbol)
    variation = kindergarten_participation_against_household_income(district_name_symbol)
    variation > 0.6 && variation < 1.5 ? true : false
  end

  def kindergarten_participation_correlates_with_household_income(district_name_symbol)
    if district_name_symbol.keys == [:for] && district_name_symbol.values != ["STATEWIDE"]
      true_or_false_kindergarten_correlates_with_income(district_name_symbol[:for])
    elsif district_name_symbol.values == ["STATEWIDE"]
      aggregated = @dr.district_objects.map do |district_object|
        true_or_false_kindergarten_correlates_with_income(district_object.name)
      end
      aggregated.count(true)/aggregated.length > 0.7 ? true : false
    elsif district_name_symbol.keys == [:across]
      aggregated = district_name_symbol[:across].map do |district_name|
        true_or_false_kindergarten_correlates_with_income(district_name)
      end
      aggregated.count(true)/aggregated.length > 0.7 ? true : false
    end
  end

  def calculate_average_of_median_household_income(district)
    total = district.economic_profile.data[:median_household_income].values.reduce do |sum, income|
      sum += income
    end
    total.to_f / (district.economic_profile.data[:median_household_income].keys.length).to_f
  end

  def truncate_value(value)
    (sprintf "%.3f", value).to_f
  end
end
