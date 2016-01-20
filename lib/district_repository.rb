require_relative 'enrollment_repository'
require_relative 'economic_profile_repository'
require_relative 'statewide_test_repository'
require_relative 'district'
require_relative 'data_utilities'

class DistrictRepository
  attr_reader :district_objects, :name, :er, :epr, :str

  def initialize(district_objects = [])
    @district_objects = district_objects
    @du = DataUtilities.new
  end

  def load_data(hash)
    DataUtilities.load_all_data(hash, district_objects)
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
