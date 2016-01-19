require_relative 'unknown_data_error'

class EconomicProfile
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def name
    @name = @data[:name]
  end

  def median_household_income_in_year(year)
    years = (2005..2015).to_a
    if !years.include?(year)
      raise UnknownDataError
    end
    sum = 0
    divisor = 0
    data_to_analyze = data[:median_household_income]
    data_to_analyze.keys.each do |all_years|
      range = (all_years[0]..all_years[1]).to_a
      if range.include?(year)
        divisor += 1
        sum += data_to_analyze[all_years]
      end
    end
    sum.to_f / divisor.to_f
  end

  def median_household_income_average
    total = data[:median_household_income].values.reduce do |sum, income|
      sum + income
    end
    average = total.to_f / (data[:median_household_income].keys.length).to_f
    DataUtilities.truncate_value(average)
  end

  def children_in_poverty_in_year(year)
    data[:children_in_poverty][year] ||= raise UnknownDataError
  end

  def free_or_reduced_price_lunch_percentage_in_year(year)
    data[:free_or_reduced_price_lunch][year][:percentage] ||=
    raise UnknownDataError
  end

  def free_or_reduced_price_lunch_number_in_year(year)
    data[:free_or_reduced_price_lunch][year][:total] ||= raise UnknownDataError
  end

  def title_i_in_year(year)
    data[:title_i][year] ||= raise UnknownDataError
  end

  def set_frl_percentage(year, number)
    data[:free_or_reduced_price_lunch][year] ||= {}
    data[:free_or_reduced_price_lunch][year][:percentage] = number
  end

  def set_frl_total(year, number)
    data[:free_or_reduced_price_lunch][year] ||= {}
    data[:free_or_reduced_price_lunch][year][:total] = number
  end
end
