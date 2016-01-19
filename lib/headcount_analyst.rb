require_relative 'district_repository'
require_relative 'result_set'
require_relative 'data_utilities'

class HeadcountAnalyst

  attr_reader :dr, :district1, :district2

  def initialize(district_respository)
    @dr = district_respository
    @dr.load_data(
      {:enrollment => {
      :kindergarten => "./data/Kindergartners in full-day program.csv",
      :high_school_graduation => "./data/High school graduation rates.csv"},
      :economic_profile => {
      :median_household_income =>
      "./data/Median household income.csv",
      :children_in_poverty =>
      "./data/School-aged children in poverty.csv",
      :free_or_reduced_price_lunch =>
      "./data/Students qualifying for free or reduced price lunch.csv",
      :title_i => "./data/Title I students.csv"}})
  end

  def kindergarten_participation_rate_variation(district1_name, district2_name)
    @district1 = @dr.find_by_name(district1_name)
    @district2 = @dr.find_by_name(district2_name[:against])
    district1_average = calculate_average_percent(district1,
                                                 :kindergarten_participation)
    district2_average = calculate_average_percent(district2,
                                                 :kindergarten_participation)
    variation = district1_average / district2_average
    DataUtilities.truncate_value(variation)
  end

  # def calculate_kindergarten_average(district)
  #   total = district.enrollment.data[:kindergarten_participation].values.reduce do |sum, participation|
  #      sum + DataUtilities.truncate_value(participation)
  #   end
  #   average = DataUtilities.truncate_value(total)/district.enrollment.data[:kindergarten_participation].length
  #   DataUtilities.truncate_value(average)
  # end

  def calculate_average_percent(district, data_to_average)
    total = district.enrollment.data[data_to_average].values.reduce do |sum, participation|
       sum + DataUtilities.truncate_value(participation)
    end
    average = DataUtilities.truncate_value(total)/
              district.enrollment.data[data_to_average].length
    DataUtilities.truncate_value(average)
  end

  def graduation_variation(district_name)
    district = dr.find_by_name(district_name)
    state = dr.find_by_name("COLORADO")
    variation = calculate_graduation_average(district) /
                calculate_graduation_average(state)
    DataUtilities.truncate_value(variation)
  end

  def calculate_graduation_average(district)
    total = district.enrollment.data[:high_school_graduation].values.reduce do |sum, participation|
       sum + participation
    end
    average = DataUtilities.truncate_value(total) /
              district.enrollment.data[:high_school_graduation].length
    DataUtilities.truncate_value(average)
  end

  def kindergarten_variation(district)
    kindergarten_participation_rate_variation(district, :against => "COLORADO")
  end

  def kindergarten_participation_rate_variation_trend(district_1, district_2)
    result = Hash.new
    district1_participation =
      @dr.find_by_name(district_1).enrollment.data[:kindergarten_participation]
    district2_participation =
      @dr.find_by_name(district_2[:against]).
      enrollment.data[:kindergarten_participation]
    district1_participation.each do |key, value|
      d1_truncated_value = DataUtilities.truncate_value(value)
      d2_truncated_value = DataUtilities.
        truncate_value(district2_participation[key])
      result[key] = DataUtilities.truncate_value(d1_truncated_value/d2_truncated_value)
    end
    result
  end

  def kindergarten_participation_against_high_school_graduation(district_name)
    result = kindergarten_variation(district_name) /
             graduation_variation(district_name)
    DataUtilities.truncate_value(result)
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
      @dr.district_objects.each do |district|
        statewide_aggregated << kindergarten_graduation_correlation(district.name)
      end
      statewide_aggregated.count(true)/statewide_aggregated.length > 0.7 ? true : false
    end
  end

  def kindergarten_graduation_correlation(district)
    variation = kindergarten_participation_against_high_school_graduation(district)
    variation > 0.6 && variation < 1.5 ? true : false
  end

  def calculate_average_frl_number(district)
    total = 0
    district.economic_profile.data[:free_or_reduced_price_lunch].each do |year|
      total += year[1][:percentage]
    end
    average = DataUtilities.truncate_value(total)/
            district.economic_profile.data[:free_or_reduced_price_lunch].length
    DataUtilities.truncate_value(average)
  end

  def calculate_avarage_percent_of_children_in_poverty(district)
    total = district.economic_profile.data[:children_in_poverty].values.reduce do |sum, participation|
       sum + DataUtilities.truncate_value(participation)
    end
    average = DataUtilities.truncate_value(total)/
              district.economic_profile.data[:children_in_poverty].length
    DataUtilities.truncate_value(average)
  end

  def high_poverty_and_high_school_graduation
    state = @dr.find_by_name("COLORADO")
    rs = ResultSet.new(:matching_districts => [],
                       :statewide_average => ResultEntry.new(
                       {:name => "COLORADO",
                       :free_and_reduced_price_lunch_rate =>
                        calculate_average_frl_number(state),
                      #:children_in_poverty_rate =>
                      #calculate_avarage_percent_of_children_in_poverty(state),
                       :high_school_graduation_rate =>
                        calculate_graduation_average(state)}))
    @dr.district_objects.each do |district|
      if calculate_average_frl_number(district) >
         calculate_average_frl_number(state) &&
         calculate_graduation_average(district) >
         calculate_graduation_average(state) #&&
         #calculate_avarage_percent_of_children_in_poverty(district) >
         #calculate_avarage_percent_of_children_in_poverty(state)
              rs.matching_districts << ResultEntry.new(
              {:name => district.name,
               :free_and_reduced_price_lunch_rate =>
               calculate_average_frl_number(district),
              #:children_in_poverty_rate =>
              #calculate_avarage_percent_of_children_in_poverty(district),
               :high_school_graduation_rate =>
               calculate_graduation_average(district)})
      end
    end
    rs
  end

  def high_income_disparity
    state = @dr.find_by_name("COLORADO")
    rs = ResultSet.new(:matching_districts => [], :statewide_average =>
        ResultEntry.new({:median_household_income =>
                        calculate_average_of_median_household_income(state),
                        #:children_in_poverty_rate =>
                        #calculate_avarage_percent_of_children_in_poverty(state)
                                            }))
    @dr.district_objects.each do |district|
      if  calculate_average_of_median_household_income(district) >
          calculate_average_of_median_household_income(state)
          #&& calculate_avarage_percent_of_children_in_poverty(district) >
          #calculate_avarage_percent_of_children_in_poverty(state)
        rs.matching_districts << ResultEntry.new(
          {:median_household_income =>
            calculate_average_of_median_household_income(district),
          #:children_in_poverty_rate =>
          #calculate_avarage_percent_of_children_in_poverty(district)
          :name => district.enrollment.data[:name]})
      end
    end
    rs
  end

  #DO WE NEED TO BE ABLE TO COMPARE THIS ACROSS DISTRICTS, OR JUST THE STATE?
  #IF YES TO THE ABOVE, DO WE NEED TO CALL IT WITH THE :against => "Colorado" FORMAT LIKE WITH KINDER
  def median_household_income_variation(district_name)
    district = @dr.find_by_name(district_name)
    state = @dr.find_by_name("COLORADO")
    calculate_average_of_median_household_income(district)/
    calculate_average_of_median_household_income(state)
  end

  def kindergarten_participation_against_household_income(district_name)
    kindergarten_participation_rate_variation(district_name,
    :against => "COLORADO") / median_household_income_variation(district_name)
  end

  def true_or_false_kindergarten_correlates_with_income(district_name)
    variation = kindergarten_participation_against_household_income(district_name)
    variation > 0.6 && variation < 1.5 ? true : false
  end

  def kindergarten_participation_correlates_with_household_income(district_name)
    if district_name.keys == [:for] && district_name.values != ["STATEWIDE"]
      true_or_false_kindergarten_correlates_with_income(district_name[:for])
    elsif district_name.values == ["STATEWIDE"]
      aggregated = @dr.district_objects.map do |district|
        true_or_false_kindergarten_correlates_with_income(district.name)
      end
      aggregated.count(true)/aggregated.length > 0.7 ? true : false
    elsif district_name.keys == [:across]
      aggregated = district_name[:across].map do |district|
        true_or_false_kindergarten_correlates_with_income(district)
      end
      aggregated.count(true)/aggregated.length > 0.7 ? true : false
    end
  end

  def calculate_average_of_median_household_income(district)
    total = district.economic_profile.data[:median_household_income].values.reduce do |sum, income|
      sum + income
    end
    total.to_f /
    (district.economic_profile.data[:median_household_income].keys.length).to_f
  end
end
