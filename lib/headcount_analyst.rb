require_relative 'district_repository'
require_relative 'result_set'
require_relative 'data_utilities'

class HeadcountAnalyst

  attr_reader :dr

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
    district1 = @dr.find_by_name(district1_name)
    district2 = @dr.find_by_name(district2_name[:against])
    district1_average = calculate_kindergarten_average(district1)
    district2_average = calculate_kindergarten_average(district2)
    variation = district1_average / district2_average
    DataUtilities.truncate_value(variation)
  end

  def kindergarten_participation_rate_variation_trend(district1_name, district2_name)
    district1_participation = @dr.find_by_name(district1_name).enrollment.data[:kindergarten_participation].values
    district2_participation = @dr.find_by_name(district2_name[:against]).enrollment.data[:kindergarten_participation].values
    years = @dr.find_by_name(district2_name[:against]).enrollment.data[:kindergarten_participation].keys
    variation = district1_participation.map.with_index do |participation, index|
      DataUtilities.truncate_value(participation / district2_participation[index])
    end
    years.zip(variation).to_h
  end

  def kindergarten_variation(district_name)
    kindergarten_participation_rate_variation(district_name, :against => "COLORADO")
  end

  def graduation_variation(district_name)
    district = dr.find_by_name(district_name)
    state = dr.find_by_name("COLORADO")
    variation = calculate_graduation_average(district) /
                calculate_graduation_average(state)
    DataUtilities.truncate_value(variation)
  end

  def kindergarten_participation_against_high_school_graduation(district_name)
    result = kindergarten_variation(district_name) /
             graduation_variation(district_name)
    DataUtilities.truncate_value(result)
  end

  def kindergarten_participation_correlates_with_high_school_graduation(district_name)
    if district_name.keys == [:across]
      aggregated = district_name[:across].map do |district|
        true_or_false_kindergarten_correlates_with_graduation(district)
      end
      aggregated_greater_or_lesser_than_seventy_percent(aggregated)
    elsif district_name[:for] != "STATEWIDE"
      true_or_false_kindergarten_correlates_with_graduation(district_name[:for])
    elsif district_name[:for] == "STATEWIDE"
      statewide_aggregated = @dr.district_objects.map do |school_district|
        true_or_false_kindergarten_correlates_with_graduation(school_district.name)
      end
      aggregated_greater_or_lesser_than_seventy_percent(statewide_aggregated)
    end
  end

  def true_or_false_kindergarten_correlates_with_graduation(district_name)
    variation = kindergarten_participation_against_high_school_graduation(district_name)
    variation > 0.6 && variation < 1.5 ? true : false
  end

  def true_or_false_kindergarten_correlates_with_income(district_name)
    variation = kindergarten_participation_against_household_income(district_name)
    variation > 0.6 && variation < 1.5 ? true : false
  end

  def calculate_average_frl_number(district)
    total = district.economic_profile.data[:free_or_reduced_price_lunch].map do |year|
      year[1][:percentage]
    end.reduce(:+)
    average = total/ district.economic_profile.data[:free_or_reduced_price_lunch].length
    DataUtilities.truncate_value(average)
  end

  def high_poverty_and_high_school_graduation
    state = @dr.find_by_name("COLORADO")
    matches = find_districts_with_high_poverty_and_hs_graduation
    rs = ResultSet.new(:matching_districts => [],
                       :statewide_average => ResultEntry.new(
                       {:name => "COLORADO",
                       :free_and_reduced_price_lunch_rate =>
                         calculate_average_frl_number(state),
                       :children_in_poverty_rate =>
                         calculate_statewide_average_children_in_poverty,
                       :high_school_graduation_rate =>
                         calculate_graduation_average(state)}))
    matches.each do |match|
      rs.matching_districts << ResultEntry.new(
      {:name => match.name,
      :free_and_reduced_price_lunch_rate =>
       calculate_average_frl_number(match),
      :children_in_poverty_rate =>
       calculate_avarage_percent_of_children_in_poverty(match),
      :high_school_graduation_rate =>
       calculate_graduation_average(match)})
    end
    rs
  end

  def find_districts_with_high_poverty_and_hs_graduation
    state = @dr.find_by_name("COLORADO")
    @dr.district_objects.select do |district|
      calculate_average_frl_number(district) >
      calculate_average_frl_number(state) &&
      calculate_graduation_average(district) >
      calculate_graduation_average(state) &&
      calculate_avarage_percent_of_children_in_poverty(district) >
      calculate_statewide_average_children_in_poverty
    end
  end

  def high_income_disparity
    state = @dr.find_by_name("COLORADO")
    matches = find_districts_with_high_income_disparity
    rs = ResultSet.new(:matching_districts => [], :statewide_average =>
         ResultEntry.new({:median_household_income =>
                          calculate_average_of_median_household_income(state),
                          :children_in_poverty_rate =>
                          calculate_statewide_average_children_in_poverty,
                          :name => "COLORADO"}))
    matches.each do |match|
      rs.matching_districts << ResultEntry.new(
      {:median_household_income =>
        calculate_average_of_median_household_income(match),
        :children_in_poverty_rate =>
        calculate_avarage_percent_of_children_in_poverty(match),
        :name =>
        match.enrollment.data[:name]})
    end
    rs
  end

  def find_districts_with_high_income_disparity
    state = @dr.find_by_name("COLORADO")
    @dr.district_objects.select do |district|
      calculate_average_of_median_household_income(district) >
      calculate_average_of_median_household_income(state) &&
      calculate_avarage_percent_of_children_in_poverty(district) >
      calculate_statewide_average_children_in_poverty
    end
  end

  def median_household_income_variation(district_name)
    district = @dr.find_by_name(district_name)
    state = @dr.find_by_name("COLORADO")
    mhi_variation = calculate_average_of_median_household_income(district)/
    calculate_average_of_median_household_income(state)
    DataUtilities.truncate_value(mhi_variation)
  end

  def kindergarten_participation_against_household_income(district_name)
    kp_hi_result = kindergarten_participation_rate_variation(district_name,:against => "COLORADO") /
      median_household_income_variation(district_name)
    DataUtilities.truncate_value(kp_hi_result)
  end

  def kindergarten_participation_correlates_with_household_income(district_name)
    if district_name.keys == [:for] && district_name.values != ["STATEWIDE"]
      true_or_false_kindergarten_correlates_with_income(district_name[:for])
    elsif district_name.values == ["STATEWIDE"]
      aggregated = @dr.district_objects.map do |district|
        true_or_false_kindergarten_correlates_with_income(district.name)
      end
      aggregated_greater_or_lesser_than_seventy_percent(aggregated)
    elsif district_name.keys == [:across]
      aggregated = district_name[:across].map do |district|
        true_or_false_kindergarten_correlates_with_income(district)
      end
      aggregated_greater_or_lesser_than_seventy_percent(aggregated)
    end
  end

  def aggregated_greater_or_lesser_than_seventy_percent(aggregated)
    aggregated.count(true)/aggregated.length > 0.7 ? true : false
  end

  def calculate_statewide_average_children_in_poverty
    district_averages = @dr.district_objects.select do |district|
      district.economic_profile.data[:children_in_poverty] != {}
    end.map do |district|
      calculate_avarage_percent_of_children_in_poverty(district)
    end
    DataUtilities.truncate_value(district_averages.reduce(:+) /
    district_averages.length)
  end

  def calculate_kindergarten_average(district)
    calculate_average_percent(district.enrollment, :kindergarten_participation)
  end

  def calculate_average_of_median_household_income(district)
    calculate_average_percent(district.economic_profile, :median_household_income)
  end

  def calculate_avarage_percent_of_children_in_poverty(district)
    calculate_average_percent(district.economic_profile, :children_in_poverty)
  end

  def calculate_graduation_average(district)
    calculate_average_percent(district.enrollment, :high_school_graduation)
  end

  def calculate_average_percent(type, data_to_average)
    total = type.data[data_to_average].values.reduce do |sum, participation|
       sum + DataUtilities.truncate_value(participation)
    end
    average = DataUtilities.truncate_value(total) /
    type.data[data_to_average].length
    DataUtilities.truncate_value(average)
  end
end
