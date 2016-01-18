require 'csv'
require_relative 'economic_profile'
require_relative 'data_utilities'

class EconomicProfileRepository
  attr_reader :economic_profile_objects, :data

  def initialize
    @economic_profile_objects = []
  end

  def load_data(hash)
    DataUtilities.load_economic_data(hash, @economic_profile_objects)
  end

  def find_by_name(name)
    economic_profile_objects.select do |economic_profile|
      if name.upcase == economic_profile.data[:name].upcase
        return economic_profile
      end
    end
  end
end
