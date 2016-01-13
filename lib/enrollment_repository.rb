require 'csv'
require_relative 'enrollment'

class EnrollmentRepository

  attr_reader :enrollment_objects, :data

  def initialize
    @enrollment_objects = []
  end

  def read_file(hash)
    hash.each do |category, path|
      @category = hash[category]
    end
    @file1 = @category[:kindergarten]
    @kindergarten_contents = CSV.open @file1, headers: true, header_converters: :symbol
    if @category[:high_school_graduation]
      @file2 = @category[:high_school_graduation]
      @hs_graduation_contents = CSV.open @file2, headers: true, header_converters: :symbol
    end
  end

  def load_data(hash)
    read_file(hash)
    @kindergarten_contents.each do |row|
      enrollment_objects << Enrollment.new({:name => row[:location], :kindergarten_participation => {row[:timeframe].to_i => row[:data].to_f}})
    end
    enrollment_objects
    if @hs_graduation_contents
      @hs_graduation_contents.each do |row|
        enrollment_objects.each do |enrollment_object|
          enrollment_object.data[:kindergarten_participation].each do |year, participation|
            if year == row[:timeframe].to_i
              enrollment_object.data[:high_school_graduation] = {row[:timeframe].to_i => row[:data].to_f}
            end
          end
        end
      end
    end
  end

  def find_by_name(name)
    #returns a hash that can be taken as the argument to create a new enrollment object
    #matches is an array of enrollment objects
    matches = []
    enrollment_objects.each do |enrollment|
      if name.upcase == enrollment.data[:name]
        matches << enrollment
      end
    end
    add_enrollment_data(matches)
  end

  def add_enrollment_data(matches)
    district_with_enrollment = matches[0].data
    district_with_enrollment[:high_school_graduation] = {}
    matches.each do |match|
      match.data[:kindergarten_participation].each do |year, participation|
        district_with_enrollment[:kindergarten_participation][year] = participation
      end
      if match.data[:high_school_graduation]
        match.data[:high_school_graduation].each do |year, participation|
          district_with_enrollment[:high_school_graduation][year] = participation
        end
      end
    end
    district_with_enrollment
  end
end
