class District
  attr_accessor :name, :enrollment, :statewide_test, :economic_profile

  def initialize(name)
    @name = name[:name].upcase
  end
end
