require_relative 'district_data_formatter'

class DistrictRepository
  attr_reader :district_objects, :name
  def initialize(district_objects = [])
    @district_objects = district_objects
  end

  def load_data(hash)
    DistrictDataFormatter.load_all_data(hash, district_objects)
  end

  def find_by_name(name)
    district_objects.find do |district|
      district.enrollment.name.upcase == name.upcase
    end
  end

  def find_all_matching(name_fragment)
    district_objects.select do |district|
      district.enrollment.name.upcase.include?(name_fragment.upcase)
    end
  end
end
