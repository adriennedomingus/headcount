require 'csv'
require_relative 'statewide_test'

class StatewideTestRepository
  attr_reader :statewide_objects, :data

  def initialize
    @statewide_objects = []
  end

  def read_file(category)
    # category = hash[:statewide_testing]

    @third_grade_contents = csv_open(category[:third_grade])
    @eighth_grade_contents = csv_open(category[:eighth_grade])
    @math_contents = csv_open(category[:math])
    @reading_contents = csv_open(category[:reading])
    @writing_contents = csv_open(category[:writing])
  end

  def csv_open(path)
    CSV.open path, headers: true, header_converters: :symbol
  end

  def load_data(hash)
    read_file(hash)
    @third_grade_contents.each do |row|
      if statewide_objects.empty?
        create_new_statewide_object_hash(row)
      else
        @third_grade_contents.each do |row|
          if statewide_objects.any? { |statewide_object| statewide_object.name == row[:location] }
            add_data_to_existing_statewide_object(row, :third_grade, :score)
          else #only do this if NONE of them match the name
            create_new_statewide_object_hash(row)
            add_data_to_existing_statewide_object(row, :third_grade, :score)
          end
        end
        @eighth_grade_contents.each do |row|
          add_data_to_existing_statewide_object(row, :eighth_grade, :score)
        end

        load_subject_data
      end
    end
  end

  def load_subject_data
    contents_hash = {
      # eigth_grade: @eighth_grade_contents,
      math: @math_contents,
      reading: @reading_contents,
      writing: @writing_contents
    }
    contents_hash.each do |subject, contents|
      contents.each do |row|
        # column = (subject == :eighth_grade ? :score : :race_ethnicity)
        add_data_to_existing_statewide_object(row, subject, :race_ethnicity) #rename type
      end
    end
  end

  def add_data_to_existing_statewide_object(row, data_type, delimeter)
    statewide_objects.each do |statewide_object|
      if row[:location] == statewide_object.name
        if statewide_object.data[data_type][row[:timeframe].to_i]
          if row[:data] == "N/A"
            statewide_object.data[data_type][row[:timeframe].to_i][row[delimeter].gsub(/\W/, "_").downcase.to_sym] = row[:data]
          else
            statewide_object.data[data_type][row[:timeframe].to_i][row[delimeter].gsub(/\W/, "_").downcase.to_sym] = row[:data].to_f
          end
        else
          if row[:data] == "N/A"
            statewide_object.data[data_type][row[:timeframe].to_i] = {row[delimeter].gsub(/\W/, "_").downcase.to_sym => row[:data]}
          else
            statewide_object.data[data_type][row[:timeframe].to_i] = {row[delimeter].gsub(/\W/, "_").downcase.to_sym => row[:data].to_f}
          end
        end
      end
    end
  end

  def create_new_statewide_object_hash(row)
    statewide_objects << StatewideTest.new({:name => row[:location],
    :third_grade => {},
    :eighth_grade => {},
    :math => {},
    :reading => {},
    :writing => {}})
  end

  def find_by_name(name)
    statewide_objects.select do |statewide|
      if name.upcase == statewide.data[:name].upcase
        return statewide
      end
    end
  end
end
