class District
  attr_reader :name
  attr_accessor :enrollment, :statewide_test, :economic_profile

  def initialize(name)
    @name = name[:name].upcase
  end
end
