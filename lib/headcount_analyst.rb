require_relative 'district_repository'

class HeadcountAnalyst

  attr_reader :dr, :district1, :district2

  def initialize(district_respository)
    @dr = district_respository
    @dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv",
                   :high_school_graduation => "./data/High school graduation rates.csv"}})
  end

  def kindergarten_participation_rate_variation(district1_name, district2_name)
    @district1 = @dr.find_by_name(district1_name)
    @district2 = @dr.find_by_name(district2_name[:against])
    district1_average = calculate_kindergarten_average(@district1)
    district2_average = calculate_kindergarten_average(@district2)
    variation = district1_average / district2_average
    variation
  end

  # def calculate_kindergarten_average(district)
  #   total = district.enrollment.data[:kindergarten_participation].values.reduce do |sum, participation|
  #      sum + truncate_value(participation)
  #   end
  #   average = truncate_value(total)/district.enrollment.data[:kindergarten_participation].length
  #   truncate_value(average)
  # end

  def calculate_kindergarten_average(district)
    total = district.enrollment.data[:kindergarten_participation].values.reduce do |sum, participation|
       sum + participation
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
    average = total/(district.enrollment.data[:high_school_graduation].length)
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
      d1_truncated_value = value
      d2_truncated_value = district2_participation[key]
      result[key] = d1_truncated_value/d2_truncated_value
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
    else
      aggregated = @dr.district_objects.map do |district_object|
        kindergarten_graduation_correlation(district_object.name)
      end
      aggregated.count(true)/aggregated.length > 0.7 ? true : false
    end
  end

  def kindergarten_graduation_correlation(district)
    variation = kindergarten_participation_against_high_school_graduation(district)
    variation > 0.6 && variation < 1.5 ? true : false
  end

  def truncate_value(value)
    (sprintf "%.3f", value).to_f
  end

  def high_poverty_and_high_school_graduation
    rs = ResultSet.new
    rs.matching_districts = []
    rs.statewide_average = ResultEntry.new({:free_and_reduced_price_lunch_rate => "we don't know this yet",
                                            :children_in_poverty_rate => "also don't know",
                                            :high_school_graduation_rate => "find me"})
    #some if loop to find matching districts
      #rs.matching_districts << if it matches
    #end
  end
end
