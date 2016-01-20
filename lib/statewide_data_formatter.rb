require 'csv'
require_relative 'statewide_test'
require_relative 'data_utilities'

class StatewideDataFormatter

  UNDEFINED_DATA = ["N/A", nil, "#DIV/0!", "#REF!", "LNE", "#VALUE!"]

  def self.read_testing_files(hash)
    category = hash[:statewide_testing]
    @third_grade_contents = DataUtilities.open_csv(category[:third_grade])
    @eighth_grade_contents = DataUtilities.open_csv(category[:eighth_grade])
    @math_contents = DataUtilities.open_csv(category[:math])
    @reading_contents = DataUtilities.open_csv(category[:reading])
    @writing_contents = DataUtilities.open_csv(category[:writing])
  end

  def self.load_testing_data(hash, statewide_objects)
    read_testing_files(hash)
    @third_grade_contents.each do |row|
      if DataUtilities.no_preexisting_object_by_current_name(statewide_objects, row)
        create_new_statewide_object_hash(statewide_objects, row)
      end
      statewide_objects.find { |statewide| statewide.name == row[:location] }
      add_data_to_existing_statewide_object(statewide_objects, row, :third_grade, :score)
    end
    @eighth_grade_contents.each do |row|
      add_data_to_existing_statewide_object(statewide_objects, row, :eighth_grade, :score)
    end
    load_subject_data(statewide_objects)
  end

  def self.add_data_to_existing_statewide_object(statewide_objects, row, data_type, delimeter)
    subject = row[delimeter].gsub(/\W/, "_").downcase.to_sym
    statewide_objects.each do |statewide|
      if row[:location] == statewide.name
        statewide.data[data_type][row[:timeframe].to_i] ||= {}
        if UNDEFINED_DATA.include?(row[:data])
          statewide.data[data_type][row[:timeframe].to_i][subject] = row[:data]
        else
          statewide.data[data_type][row[:timeframe].to_i][subject] = DataUtilities.truncate_value(row[:data].to_f)
        end
      end
    end
  end

  def self.load_subject_data(statewide_objects)
    contents_hash = {math: @math_contents,
      reading: @reading_contents,
      writing: @writing_contents}
    contents_hash.each do |subject, contents|
      contents.each do |row|
        add_data_to_existing_statewide_object(statewide_objects, row, subject, :race_ethnicity)
      end
    end
  end

  def self.create_new_statewide_object_hash(statewide_objects, row)
    statewide_objects << StatewideTest.new({:name => row[:location],
    :third_grade => {},
    :eighth_grade => {},
    :math => {},
    :reading => {},
    :writing => {}})
  end
end
