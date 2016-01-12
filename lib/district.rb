require_relative 'district_repository'

class District

  attr_accessor :name

  def initialize(name)
    @name = name[:name].upcase
  end

  def enrollment
    #access the enrollment repository
    #find by name on er using name of district object
      # =>  create an Enrollment object using return value of find by name
    #call kindergarten_participation_in_year on created Enrollment object
  end

end
