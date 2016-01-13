require_relative 'district_repository'

class HeadcountAnalyst

  attr_accessor :dr, :district1, :district2

  def initialize(district_respository)
    @dr = district_respository
    @dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
  end

  def kindergarten_participation_rate_variation(district1, district2)
    @district1 = @dr.find_by_name(district1)
    @district2 = @dr.find_by_name(district2[:against])
  end
end
