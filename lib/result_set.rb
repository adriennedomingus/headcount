require_relative 'result_entry'

class ResultSet

  attr_reader :matching_districts
  attr_accessor :statewide_average

  def initialize(hash)
    @matching_districts = []
  end
end
