require 'csv'
require_relative 'statewide_test'

class StatewideTestRepository
  attr_reader :statewide_objects, :data

  def initialize
    @statewide_objects = []
  end

  def read_file(hash)
    hash.each do |category, path|
      @category = hash[category]
    end
    @grade_3 = @category[:third_grade]
    @third_grade_contents = CSV.open @grade_3, headers: true, header_converters: :symbol
    @grade_8 = @category[:eighth_grade]
    @eighth_grade_contents = CSV.open @grade_8, headers: true, header_converters: :symbol
    @math = @category[:math]
    @math_contents = CSV.open @math, headers: true, header_converters: :symbol
    @reading = @category[:reading]
    @reading_contents = CSV.open @reading, headers: true, header_converters: :symbol
    @writing = @category[:writing]
    @writing_contents = CSV.open @writing, headers: true, header_converters: :symbol
  end

  def load_data(hash)
    read_file(hash)
    @third_grade_contents.each do |row|
      if statewide_objects.empty?
        create_blank_statewide_test_object(row)
      else
        if statewide_objects.any? { |statewide_object| statewide_object.name == row[:location] }
          add_data_to_existing_object(row, :third_grade, :score)
        else #only do this if NONE of them match the name
          create_blank_statewide_test_object(row)
        end
        @eighth_grade_contents.each do |row|
          add_data_to_existing_object(row, :eighth_grade, :score)
        end
        @math_contents.each do |row|
          add_data_to_existing_object(row, :math, :race_ethnicity)
        end
        @reading_contents.each do |row|
          add_data_to_existing_object(row, :reading, :race_ethnicity)
        end
        @writing_contents.each do |row|
          add_data_to_existing_object(row, :writing, :race_ethnicity)
        end
      end
    end
  end

  def add_data_to_existing_object(row, subject, delimeter)
    statewide_objects.each do |statewide_object|
      if row[:location] == statewide_object.name
        if statewide_object.data[subject][row[:timeframe].to_i]
          statewide_object.data[subject][row[:timeframe].to_i][row[delimeter].gsub(/\W/, "_").downcase.to_sym] = row[:data].to_f
        else
          statewide_object.data[subject][row[:timeframe].to_i] = {row[delimeter].gsub(/\W/, "_").downcase.to_sym => row[:data].to_f}
        end
      end
    end
  end

  def create_blank_statewide_test_object(row)
    statewide_objects << StatewideTest.new({:name => row[:location],
    :third_grade => {},
    :eighth_grade => {},
    :math => {},
    :reading => {},
    :writing => {}})
  end

  def find_by_name(name)
    statewide_objects.select do |statewide|
      require "pry"
      binding.pry
      if name.upcase == statewide.data[:name].upcase
        return statewide
      end
    end
  end
end
