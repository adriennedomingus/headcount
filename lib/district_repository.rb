require 'csv'
require_relative 'district'
require_relative 'enrollment_repository'
require_relative 'statewide_test_repository'
require_relative 'economic_profile_repository'

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
    @er.enrollment_objects.each do |enrollment_object|
      if enrollment_object.data[:name] == @district.name
        enrollment_matches << enrollment_object.data[:kindergarten_participation]
      end
    end
    @er.enrollment_objects.each do |enrollment_object|
      if enrollment_object.data[:high_school_graduation]
        if enrollment_object.data[:name] == @district.name
          hs_graduation_matches << enrollment_object.data[:high_school_graduation]
        end
      end
    end
    enrollment_data = Hash.new
    enrollment_matches.each do |hash|
      hash.each do |year, participation|
        enrollment_data[year] = participation
      end
    end
    if @str
      @str.statewide_objects.each do |statewide_object|
        if statewide_object.data[:name] == @district.name
          @statewide_object = statewide_object
        end
      end
      @district.statewide_test = StatewideTest.new(@statewide_object.data)
    end
    if @epr
      @epr.economic_profile_objects.each do |economic_profile_object|
        if economic_profile_object.data[:name] == @district.name
          @economic_profile_object = economic_profile_object
        end
      end
      @district.economic_profile = EconomicProfile.new(@economic_profile_object.data)
    end
    hs_graduation_data = Hash.new
    hs_graduation_matches.each do |hash|
      hash.each do |year, graduation_rate|
        hs_graduation_data[year] = graduation_rate
      end
    end
    @district.enrollment = Enrollment.new({:name => @district.name, :kindergarten_participation => enrollment_data, :high_school_graduation => hs_graduation_data})
    @district
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
    @er = EnrollmentRepository.new
    @er.load_data({:enrollment => hash[:enrollment]})
    if hash[:statewide_testing]
      @str = StatewideTestRepository.new
      @str.load_data({:statewide_testing => hash[:statewide_testing]})
    end
    if hash[:economic_profile]
      @epr = EconomicProfileRepository.new
      @epr.load_data({:statewide_testing => hash[:economic_profile]})
    end
    upcase_names_in_enrollment_repository
    @district_objects
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
