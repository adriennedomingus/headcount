class EconomicProfile
  attr_reader :data, :name

  def initialize(data)
    @data = data
  end

  def name
    @name = @data[:name]
  end

  def median_household_income_in_year(year)
    #UNKNOWNDATAERROR
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
    data[:children_in_poverty][:percent][year]
  end

  def free_or_reduced_price_lunch_percentage_in_year(year)
    data[:free_or_reduced_price_lunch][:percent][year]
  end

  def free_or_reduced_price_lunch_number_in_year(year)
    data[:free_or_reduced_price_lunch][:number][year]
  end

  def title_i_in_year(year)
    data[:title_i][year]
  end
end
