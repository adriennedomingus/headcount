require 'csv'
require_relative 'statewide_test'
require_relative 'data_utilities'

class StatewideTestRepository
  attr_reader :statewide_objects, :data

  def initialize
    @statewide_objects = []
  end

  def load_data(hash)
    DataUtilities.load_testing_data(hash, @statewide_objects)
  end

  def find_by_name(name)
    statewide_objects.find do |statewide|
      name.upcase == statewide.data[:name].upcase
    end
  end
end
