class StatewideTest

  attr_reader :data, :name

  def initialize(data)
    @data = data
  end

  def name
    @name = @data[:name]
  end

  def proficient_by_grade(grade)
    if grade == 3
      data[:third_grade]
    elsif grade == 8
      data[:eighth_grade]
    else
      "do something here later"
    end
  end

  def proficient_by_race_or_ethnicity(race)
    result = {}
    reading_data = data[:reading]
    writing_data = data[:writing]
    math_data = data[:math]
    math_data.each do |year, data|
      result[year] = {:math => math_data[year][race]}
    end
    reading_data.each do |year, data|
      data.each do
        result[year][:reading] = reading_data[year][race]
      end
    end
    writing_data.each do |year, data|
      data.each do
        result[year][:writing] = writing_data[year][race]
      end
    end
    result
  end

  def proficient_for_subject_by_grade_in_year(subject, grade, year)
    grade_level_data = proficient_by_grade(grade)
    grade_level_data[year][subject]
  end

  def proficient_for_subject_by_race_in_year(subject, race, year)
    race_data = proficient_by_race_or_ethnicity(race)
    race_data[year][subject]
  end
end
