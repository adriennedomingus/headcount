class District

  attr_accessor :name

  def initialize(name)
    @name = name[:name].upcase
  end

  def enrollment
  end

end
