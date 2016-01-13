require 'csv'
require_relative 'district'
require_relative 'enrollment_repository'

class DistrictRepository

  attr_accessor :district_objects

  def initialize
    # @districts = []
    @district_objects = []
  end

  def find_by_name(district_name)
    #returns an instance of District with an enrollment thing :name =>"ACA", :kindergarten=>{year,part}
    @enrollment_matches = []
    @district_objects.each do |district|
      if district.name == district_name.upcase
        @district = district
      end
    end
    @er.each do |enrollment_object|
      if enrollment_object.data[:name] == @district.name
        @enrollment_matches << enrollment_object.data[:kindergarten_participation]
      end
    end
    @enrollment_data = @enrollment_matches[0]
    @enrollment_matches.each do |hash|
      hash.each do |year, participation|
        @enrollment_data[year] = participation
      end
    end
    @district.enrollment = Enrollment.new({:name => @district.name, :kindergarten_participation => @enrollment_data})
    @district
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
    @category.each do |file_contents, file_to_open|
      @file = @category[file_contents]
    end
    @contents = CSV.open @file, headers: true, header_converters: :symbol
  end

  def load_data(hash)
    districts = []
    read_file(hash)
    @contents.each do |row|
      districts << row[:location]
    end
    districts.uniq!
    districts.each do |district|
       @district_objects << District.new({:name => district})
    end
    @er = create_enrollment_repo(hash)
    @district_objects
  end

  def create_enrollment_repo(hash)
    EnrollmentRepository.new.load_data(hash)
  end
end
