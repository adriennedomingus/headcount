require_relative 'unknown_data_error'

class EconomicProfile
  attr_reader :data, :name

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
    data_to_analyze.keys.each do |years|
      range = (years[0]..years[1]).to_a
      if range.include?(year)
        divisor += 1
        sum += data_to_analyze[years]
      end
    end
    sum.to_f / divisor.to_f
  end

  def median_household_income_average
    total = data[:median_household_income].values.reduce do |sum, income|
      sum += income
    end
    total.to_f / (data[:median_household_income].keys.length).to_f
  end

  def children_in_poverty_in_year(year)
    if data[:children_in_poverty][year]
      data[:children_in_poverty][year]
    else
      raise UnknownDataError
    end
  end

  def free_or_reduced_price_lunch_percentage_in_year(year)
    if data[:free_or_reduced_price_lunch][year][:percentage]
      data[:free_or_reduced_price_lunch][year][:percentage]
    else
      raise UnknownDataError
    end
  end

  def free_or_reduced_price_lunch_number_in_year(year)
    if data[:free_or_reduced_price_lunch][year][:total]
      data[:free_or_reduced_price_lunch][year][:total]
    else
      raise UnknownDataError
    end
  end

  def title_i_in_year(year)
    if data[:title_i][year]
      data[:title_i][year]
    else
      raise UnknownDataError
    end
  end
end
