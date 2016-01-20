require_relative 'enrollment'
require 'csv'
require_relative 'data_utilities'

class EnrollmentRepository

  attr_reader :enrollment_objects

  def initialize(enrollment_objects = [])
    @enrollment_objects = enrollment_objects
  end

  def load_data(hash)
    DataUtilities.load_enrollment_data(hash, enrollment_objects)
  end

  def find_by_name(name)
    @enrollment_objects.find do |enrollment|
      enrollment.name == name.upcase
    end
  end
end
