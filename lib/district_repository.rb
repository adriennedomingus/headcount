require 'csv'
require_relative 'district'
require_relative 'enrollment_repository'

class DistrictRepository

  attr_reader :district_objects

  def initialize
    @district_objects = []
  end

  def find_by_name(district_name)
    #returns an instance of District with an enrollment parameter :name =>"ACA", :kindergarten=>{year,participation}
    find_name_matches(district_name)
    enrollment_matches = []
    @er.each do |enrollment_object|
      if enrollment_object.data[:name] == @district.name
        enrollment_matches << enrollment_object.data[:kindergarten_participation]
      end
    end
    enrollment_data = Hash.new
    enrollment_matches.each do |hash|
      hash.each do |year, participation|
        enrollment_data[year] = participation
      end
    end
    @district.enrollment = Enrollment.new({:name => @district.name, :kindergarten_participation => enrollment_data})
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
    @er = create_enrollment_repository(hash)
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

  def create_enrollment_repository(hash)
    EnrollmentRepository.new.load_data(hash)
  end

  def upcase_names_in_enrollment_repository
    @er.each do |enrollment_object|
      enrollment_object.data[:name] = enrollment_object.data[:name].upcase
    end
  end
end
