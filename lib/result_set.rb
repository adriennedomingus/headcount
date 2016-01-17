require_relative 'result_entry'

class ResultSet

  attr_reader :matching_districts, :statewide_average

  def initialize(hash)
    @matching_districts = hash[:matching_districts]
    @statewide_average = hash[:statewide_average]
  end
end
