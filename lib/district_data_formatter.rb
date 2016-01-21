require_relative 'enrollment_repository'
require_relative 'economic_profile_repository'
require_relative 'statewide_test_repository'
require_relative 'district'
require_relative 'data_utilities'

class DistrictDataFormatter

  def read_district_files
    @contents = DataUtilities.open_csv("./data/Kindergartners in full-day program.csv")
  end

  def load_all_data(files, district_objects)
    read_district_files
    @contents.each do |row|
      if DataUtilities.no_object_by_current_name(district_objects, row)
        district_objects << District.new({:name => row[:location]})
      end
    end
    if files[:statewide_testing]
      create_new_statewide_testing_objects(files, district_objects)
    end
    if files[:economic_profile]
      create_new_economic_profile_objects(files, district_objects)
    end
    create_new_enrollment_repository(files)
    match_enrollment_objects_to_district_object(district_objects)
  end


  def create_new_enrollment_repository(files)
    @er = EnrollmentRepository.new
    if !files[:enrollment][:high_school_graduation]
      @er.load_data(:enrollment =>
                   {:kindergarten => files[:enrollment][:kindergarten]})
    else
      @er.load_data(:enrollment => files[:enrollment])
    end
  end

  def match_enrollment_objects_to_district_object(district_objects)
    district_objects.each do |district|
      match = find_matching_object_by_name(district, @er.enrollment_objects)
      district.enrollment = Enrollment.new(match.data)
    end
  end

  def create_new_statewide_testing_objects(files, district_objects)
    @str = StatewideTestRepository.new
    @str.load_data(:statewide_testing => files[:statewide_testing])
    district_objects.each do |district|
      match = find_matching_object_by_name(district, @str.statewide_objects)
      district.statewide_test = StatewideTest.new(match.data)
    end
  end

  def find_matching_object_by_name(district, repository)
    repository.find do |data_holder|
      data_holder.data[:name].upcase == district.name
    end
  end

  def create_new_economic_profile_objects(files, district_objects)
    @epr = EconomicProfileRepository.new
    @epr.load_data(:economic_profile => files[:economic_profile])
    district_objects.each do |district|
      match = @epr.economic_profile_objects.find do |economic_profile|
        economic_profile.data[:name].upcase == district.name.upcase
      end
      district.economic_profile = EconomicProfile.new(match.data)
    end
  end
end
