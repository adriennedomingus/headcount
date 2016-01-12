require 'csv'
require_relative 'enrollment'

class EnrollmentRepository

  attr_accessor :enrollment_objects

  def initialize
    @enrollment_objects = []
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
      @enrollment_objects << Enrollment.new({:name => row[:location], :kindergarten_participation => {row[:timeframe].to_i => row[:data].to_f}})
    end
    @enrollment_objects
  end

  def find_by_name
  end

end
