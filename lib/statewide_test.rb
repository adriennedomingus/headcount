require_relative 'unknown_data_error'

class StatewideTest
  attr_reader :data, :name

  def initialize(data)
    @data = data
  end

  POSSIBLE_RACES = [:all_students, :asian, :black, :hawaiian_pacific_islander, :hispanic, :native_american, :two_or_more, :white]
  POSSIBLE_GRADES = [3, 8]
  POSSIBLE_SUBJECTS = [:math, :reading, :writing]

  def name
    @name = @data[:name]
  end

  def proficient_by_grade(grade)
    if !POSSIBLE_GRADES.include?(grade)
      raise UnknownDataError
    end
    if grade == 3
      data[:third_grade]
    else grade == 8
      data[:eighth_grade]
    end
  end

  def proficient_by_race_or_ethnicity(race)
    if !POSSIBLE_RACES.include?(race)
      raise UnknownDataError
    end
    result = {}
    reading_data = data[:reading]
    writing_data = data[:writing]
    math_data = data[:math]
    math_data.each do |year, data|
      result[year] = {:math => math_data[year][race]}
    end
    #can we also pull lines 41 and 44 into method starting on line 50?
    reading_data.each do |year, data|
      add_data_by_race(reading_data, result, :reading, year, race)
    end
    writing_data.each do |year, data|
      add_data_by_race(writing_data, result, :writing, year, race)
    end
    result
  end

  def add_data_by_race(data, result, subject, year, race)
    data.each do
      result[year][subject] = data[year][race]
    end
  end

  def proficient_for_subject_by_grade_in_year(subject, grade, year)
    if !POSSIBLE_SUBJECTS.include?(subject) || !POSSIBLE_GRADES.include?(grade)
      raise UnknownDataError
    end
    grade_level_data = proficient_by_grade(grade)
    grade_level_data[year][subject]
  end

  def proficient_for_subject_by_race_in_year(subject, race, year)
    if !POSSIBLE_SUBJECTS.include?(subject) || !POSSIBLE_RACES.include?(race)
      raise UnknownDataError
    end
    race_data = proficient_by_race_or_ethnicity(race)
    race_data[year][subject]
  end
end
