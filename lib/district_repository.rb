require_relative 'district_data_formatter'

class DistrictRepository
  attr_reader :district_objects, :name

  def initialize(district_objects = [])
    @district_objects = district_objects
    @formatter = DistrictDataFormatter.new
  end

  def load_data(files)
    @formatter.load_all_data(files, district_objects)
  end

  def find_by_name(district_name)
    district_objects.find do |district|
      district.enrollment.name.upcase == district_name.upcase
    end
  end

  def find_all_matching(name_fragment)
    district_objects.select do |district|
      district.enrollment.name.upcase.include?(name_fragment.upcase)
    end
  end
end
