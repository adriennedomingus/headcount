class Enrollment

  attr_reader :data, :name

  def initialize(data)
    @data = data
  end

  def name
    @name = @data[:name]
  end

  def kindergarten_participation_by_year
    data[:kindergarten_participation]
  end

  def kindergarten_participation_in_year(year)
    data[:kindergarten_participation][year]
  end

  def graduation_rate_by_year
    #write another test for this in er, running through the whole thing
    data[:high_school_graduation]
  end

  def graduation_rate_in_year(year)
    data[:high_school_graduation][year]
  end
end
