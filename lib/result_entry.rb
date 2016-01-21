class ResultEntry
  attr_reader :free_and_reduced_price_lunch_rate,
              :children_in_poverty_rate,
              :high_school_graduation_rate,
              :median_household_income,
              :name

  def initialize(hash)
    @name = hash[:name]
    @free_and_reduced_price_lunch_rate =
      hash[:free_and_reduced_price_lunch_rate]
    @children_in_poverty_rate = hash[:children_in_poverty_rate]
    @high_school_graduation_rate = hash[:high_school_graduation_rate]
    @median_household_income = hash[:median_household_income]
  end
end
