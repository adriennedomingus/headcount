require_relative 'economic_data_formatter'

class EconomicProfileRepository
  attr_reader :economic_profile_objects, :data

  def initialize
    @economic_profile_objects = []
  end

  def name
    economic_profile.data[:name]
  end

  def load_data(hash)
    EconomicDataFormatter.load_economic_data(hash, economic_profile_objects)
  end

  def find_by_name(district_name)
    economic_profile_objects.select do |economic_profile|
      if district_name.upcase == economic_profile.name.upcase
        return economic_profile
      end
    end
  end
end
