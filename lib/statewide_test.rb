class StatewideTest

  attr_reader :data, :name

  def initialize(data)
    @data = data
  end

  def name
    @name = @data[:name]
  end
end
