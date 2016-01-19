require_relative 'enrollment_repository'
require_relative 'economic_profile_repository'
require_relative 'statewide_test_repository'
require_relative 'district'
require_relative 'data_utilities'

class DistrictRepository
  attr_reader :district_objects, :name, :er, :epr, :str

  def initialize(district_objects = [])
    @district_objects = district_objects
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

  def load_data(hash)
    read_district_files
    @contents.each do |row|
      if DataUtilities.no_preexisting_object_by_current_name(district_objects, row)
        district_objects << District.new({:name => row[:location]})
      end
    end
    if hash[:statewide_testing]
      create_new_statewide_testing_objects(hash, district_objects)
    end
    if hash[:economic_profile]
      create_new_economic_profile_objects(hash, district_objects)
    end
    create_new_enrollment_repository(hash)
    match_enrollment_objects_to_district_object(district_objects)
  end

  def read_district_files
    @contents = DataUtilities.open_csv( "./data/Kindergartners in full-day program.csv")
  end

  def create_new_enrollment_repository(hash)
    @er = EnrollmentRepository.new
    if !hash[:enrollment][:high_school_graduation]
      @er.load_data(:enrollment =>
                   {:kindergarten => hash[:enrollment][:kindergarten]})
    else
      @er.load_data(:enrollment => hash[:enrollment])
    end
  end

  def match_enrollment_objects_to_district_object(district_objects)
    district_objects.each do |district|
      match = @er.enrollment_objects.find do |enrollment|
        enrollment.data[:name].upcase == district.name
      end
      district.enrollment = Enrollment.new(match.data)
    end
  end

  def create_new_statewide_testing_objects(hash, district_objects)
    @str = StatewideTestRepository.new
    @str.load_data(:statewide_testing => hash[:statewide_testing])
    district_objects.each do |district|
      match = @str.statewide_objects.find do |statewide|
        statewide.data[:name].upcase == district.name
      end
      district.statewide_test = StatewideTest.new(match.data)
    end
  end

  def create_new_economic_profile_objects(hash, district_objects)
    @epr = EconomicProfileRepository.new
    @epr.load_data(:economic_profile => hash[:economic_profile])
    district_objects.each do |district|
      match = @epr.economic_profile_objects.find do |economic_profile|
        economic_profile.data[:name].upcase == district.name.upcase
      end
      district.economic_profile = EconomicProfile.new(match.data)
    end
  end
end
