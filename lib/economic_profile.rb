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
    raise UnknownDataError if !years.include?(year)
    data_to_analyze = data[:median_household_income]
    included = data_to_analyze.keys.map do |all_years|
      range = (all_years[0]..all_years[1]).to_a
      if range.include?(year)
        data_to_analyze[all_years]
      end
    end.delete_if { |value| value == nil }
    sum = included.reduce(:+)
    sum.to_f / included.length.to_f
  end

  def median_household_income_average
    total = data[:median_household_income].values.reduce do |sum, income|
      sum + income
    end.to_f
    total / (data[:median_household_income].keys.length).to_f
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

  def set_free_or_reduced_price_lunch_percentage(year, number)
    data[:free_or_reduced_price_lunch][year] ||= {}
    data[:free_or_reduced_price_lunch][year][:percentage] = number
  end

  def set_free_or_reduced_price_lunch_total(year, number)
    data[:free_or_reduced_price_lunch][year] ||= {}
    data[:free_or_reduced_price_lunch][year][:total] = number
  end
end
