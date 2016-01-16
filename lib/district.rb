require_relative 'district_repository'

class District
  attr_accessor :name, :enrollment, :statewide_test

  def initialize(name)
    @name = name[:name].upcase
  end
end
