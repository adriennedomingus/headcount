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

  def calcultate_average(district)
    total = 0
    district.enrollment.data[:kindergarten_participation].each_value do |value|
      total += (Integer(value *1000)/ Float(1000) )
    end
    average = (Integer(total*1000)/ Float(1000) )/district.enrollment.data[:kindergarten_participation].length
    (Integer(average*1000)/ Float(1000) )
  end
end



#{2007=>0.39159, 2006=>0.35364, 2005=>0.26709, 2004=>0.30201, 2008=>0.38456, 2009=>0.39, 2010=>0.43628, 2011=>0.489, 2012=>0.47883, 2013=>0.48774, 2014=>0.49022}}>>
