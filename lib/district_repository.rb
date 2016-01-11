require 'csv'
require_relative 'district'

class DistrictRepository

  attr_accessor :districts, :district_objects

  def initialize
    @districts = []
    @district_objects = []
    @contents = CSV.open"../data/Kindergartners_in_full-day_program.csv", headers: true, header_converters: :symbol
  end

  def find_by_name(district_name)
    matches = []
    @district_objects.each do |district|
      if district.name == district_name
        matches << district
      end
    end
    matches
  end

  def find_all_matching
  end

  def load_data
    @contents.each do |row|
      @districts << row[:location]
    end
    @districts.uniq!
    @districts.delete_at(0)
    @districts.each do |district|
       @district_objects << District.new({:name => district})
    end
    @district_objects
  end
end

d = DistrictRepository.new
d.load_data
