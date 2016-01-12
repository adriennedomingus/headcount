require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/enrollment_repository'

class EnrollmentRepositoryTest < MiniTest::Test

  def test_loads_data
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "../data/Kindergartners in full-day program.csv"}})
    result = {:name=>"ACADEMY 20", :kindergarten_participation=>{2010=>0.43628}}

    assert_equal result, er.enrollment_objects[17].data
  end
end
