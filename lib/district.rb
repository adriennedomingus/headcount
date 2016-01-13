require_relative 'district_repository'

class District

  attr_accessor :name, :enrollment

  def initialize(name)
    @name = name[:name].upcase
  end



end
