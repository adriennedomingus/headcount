require_relative  'statewide_data_formatter'

class StatewideTestRepository
  attr_reader :statewide_objects, :data

  def initialize
    @statewide_objects = []
    @formatter = StatewideDataFormatter.new
  end

  def load_data(files)
    @formatter.load_testing_data(files, statewide_objects)
  end

  def find_by_name(district_name)
    statewide_objects.find do |statewide|
      district_name.upcase == statewide.name.upcase
    end
  end
end
