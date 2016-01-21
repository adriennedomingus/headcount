require_relative 'economic_data_formatter'

class EconomicProfileRepository
  attr_reader :economic_profile_objects, :data

  def initialize
    @economic_profile_objects = []
    @formatter = EconomicDataFormatter.new
  end

  def load_data(files)
    @formatter.load_economic_data(files, economic_profile_objects)
  end

  def find_by_name(district_name)
    economic_profile_objects.select do |economic_profile|
      if district_name.upcase == economic_profile.name.upcase
        return economic_profile
      end
    end
  end
end
