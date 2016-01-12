class Enrollment

  attr_reader :data, :name

  def initialize(data)
    @data = data
  end

  def name
    @name = @data[:name]
  end

  def kindergarten_participation_by_year
    num = data[:kindergarten_participation]
  end

  def kindergarten_participation_in_year(year)
    data[:kindergarten_participation][year]
  end
end
