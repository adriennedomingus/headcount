require_relative 'district_repository'

class HeadcountAnalyst

  attr_reader :dr, :district1, :district2

  def initialize(district_respository)
    @dr = district_respository
    @dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
  end

  def kindergarten_participation_rate_variation(district1_name, district2_name)
    @district1 = @dr.find_by_name(district1_name)
    @district2 = @dr.find_by_name(district2_name[:against])
    district1_average = calculate_average(@district1)
    district2_average = calculate_average(@district2)
    variation = district1_average / district2_average
    truncate_value(variation)
  end

  def calculate_average(district)
    total = district.enrollment.data[:kindergarten_participation].values.reduce do |sum, participation|
       sum + truncate_value(participation)
    end
    average = truncate_value(total)/district.enrollment.data[:kindergarten_participation].length
    truncate_value(average)
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

  def truncate_value(value)
    (Integer(value * 1000)/ Float(1000) )
  end
end
