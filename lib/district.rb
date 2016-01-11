class District

  attr_accessor :name

  def initialize(name)
    @name = name[:name].upcase
  end

end
