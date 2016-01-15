require 'csv'
require_relative 'district'
require_relative 'enrollment_repository'
require_relative 'statewide_test_repository'

class DistrictRepository

  attr_reader :district_objects, :er

  def initialize
    @district_objects = []
  end

  def find_by_name(district_name)
    #returns an instance of District with an enrollment parameter :name =>"ACA", :kindergarten=>{year,participation}
    find_name_matches(district_name)
    enrollment_matches = []
    hs_graduation_matches = []
    add_enrollment_data_to_matches(enrollment_matches, :kindergarten_participation)
    add_enrollment_data_to_matches(hs_graduation_matches, :high_school_graduation)
    enrollment_data = Hash.new
    hs_graduation_data = Hash.new
    create_enrollment_data(enrollment_matches, enrollment_data)
    create_enrollment_data(hs_graduation_matches, hs_graduation_data)
    @district.enrollment = Enrollment.new({:name => @district.name, :kindergarten_participation => enrollment_data, :high_school_graduation => hs_graduation_data})
    if @str
      add_statewide_test_object_to_match
    end
    @district
  end

  def add_statewide_test_object_to_match
    @str.statewide_objects.each do |statewide_object|
      if statewide_object.data[:name] == @district.name
        @statewide_object = statewide_object
      end
    end
    @district.statewide_test = StatewideTest.new(@statewide_object.data)
  end

  def create_enrollment_data(matches, data_container)
    matches.each do |hash|
      hash.each do |year, data_point|
        data_container[year] = data_point
      end
    end
  end

  def add_enrollment_data_to_matches(matches, data)
    @er.enrollment_objects.each do |enrollment_object|
      if enrollment_object.data[:name] == @district.name
        matches << enrollment_object.data[data]
      end
    end
  end

  def find_name_matches(district_name)
    @district_objects.each do |district|
      if district.name == district_name.upcase
        @district = district
      end
    end
  end

  def find_all_matching(name_fragment)
    matches = []
    @district_objects.each do |district|
      if district.name.include?(name_fragment.upcase)
        matches << district
      end
    end
    matches
  end

  def read_file(hash)
    hash.each do |category, path|
      @category = hash[category]
    end
    @category.each_key do |file_contents|
      @file = @category[file_contents]
    end
    @contents = CSV.open @file, headers: true, header_converters: :symbol
  end

  def load_data(hash)
    read_file(hash)
    districts = read_locations_from_contents
    create_district_objects(districts)
    create_enrollment_repository(hash)
    if hash[:statewide_testing]
      create_statewide_test_repository(hash)
    end
    upcase_names_in_enrollment_repository
    @district_objects
  end

  def create_enrollment_repository(hash)
    @er = EnrollmentRepository.new
    @er.load_data({:enrollment => hash[:enrollment]})
  end

  def create_statewide_test_repository(hash)
    @str = StatewideTestRepository.new
    @str.load_data({:statewide_testing => hash[:statewide_testing]})
  end

  def create_district_objects(districts)
    @district_objects = districts.map do |district|
       District.new({:name => district})
    end
  end

  def read_locations_from_contents
    @contents.map do |row|
      row[:location]
    end.uniq!
  end

  def upcase_names_in_enrollment_repository
    @er.enrollment_objects.each do |enrollment_object|
      enrollment_object.data[:name] = enrollment_object.data[:name].upcase
    end
  end
end
