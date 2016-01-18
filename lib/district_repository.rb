require_relative 'enrollment_repository'
require_relative 'economic_profile_repository'
require_relative 'statewide_test_repository'
require_relative 'district'

class DistrictRepository

  attr_reader :district_objects, :name, :er, :epr, :str

  def initialize
    @district_objects = []
  end

  def load_data(hash)
    read_file(hash)
    @contents.each do |row|
      if district_objects.empty?
        district_objects << District.new({:name => row[:location]})
      elsif !district_objects.any? { |district_object| district_object.name == row[:location].upcase }
        district_objects << District.new({:name => row[:location]})
      end
    end
    if hash[:statewide_testing]
      @str = StatewideTestRepository.new
      @str.load_data(:statewide_testing => hash[:statewide_testing])
      district_objects.each do |district_object|
        @str.statewide_objects.each do |statewide_object|
          if statewide_object.data[:name].upcase == district_object.name
            district_object.statewide_test = StatewideTest.new(statewide_object.data)
          end
        end
      end
    end
    if hash[:economic_profile]
      @epr = EconomicProfileRepository.new
      @epr.load_data(:economic_profile => hash[:economic_profile])
      district_objects.each do |district_object|
        @epr.economic_profile_objects.each do |economic_profile_object|
          if economic_profile_object.data[:name].upcase == district_object.name.upcase
            district_object.economic_profile = EconomicProfile.new(economic_profile_object.data)
          end
        end
      end
    end
    @er = EnrollmentRepository.new
    if !hash[:enrollment][:high_school_graduation]
      @er.load_data(:enrollment => {:kindergarten => hash[:enrollment][:kindergarten]})
    else
      @er.load_data(:enrollment => hash[:enrollment])
    end
    district_objects.each do |district_object|
      @er.enrollment_objects.each do |enrollment_object|
        if enrollment_object.data[:name].upcase == district_object.name
          district_object.enrollment = Enrollment.new(enrollment_object.data)
        end
      end
    end
  end

  def find_by_name(name)
    district_objects.find do |district_object|
      district_object.enrollment.data[:name].upcase == name.upcase
    end
  end

  def find_all_matching(name_fragment)
    district_objects.select do |district_object|
      district_object.enrollment.data[:name].upcase.include?(name_fragment.upcase)
    end
  end

  def read_file(hash)
    @contents = CSV.open "./data/Kindergartners in full-day program.csv", headers: true, header_converters: :symbol
  end
end
