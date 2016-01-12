require 'csv'
require_relative 'district'
require_relative 'enrollment_repository'

class DistrictRepository

  attr_accessor :districts, :district_objects

  def initialize
    @districts = []
    @district_objects = []
  end

  def find_by_name(district_name)
    #returns an instance of District
    @district_objects.each do |district|
      if district.name == district_name.upcase
        district
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
    @category.each do |file_contents, file_to_open|
      @file = @category[file_contents]
    end
    @contents = CSV.open @file, headers: true, header_converters: :symbol
  end

  def load_data(hash)
    read_file(hash)
    @contents.each do |row|
      @districts << row[:location]
    end
    @districts.uniq!
    @districts.each do |district|
       @district_objects << District.new({:name => district})
    end
    create_enrollment_repo(hash)
    @district_objects
  end

  def create_enrollment_repo(hash)
    EnrollmentRepository.new.load_data(hash)
  end

  #def first_step
    #dr.load data
      #returns Array of district objects connected to name
    #WANT to create Enroll Repo and load data
      #return Array of Enroll objects
  #end
end
