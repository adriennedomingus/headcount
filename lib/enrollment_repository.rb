require_relative 'enrollment_data_formatter'

class EnrollmentRepository

  attr_reader :enrollment_objects

  def initialize(enrollment_objects = [])
    @enrollment_objects = enrollment_objects
  end

  def load_data(hash)
    EnrollmentDataFormatter.load_enrollment_data(hash, enrollment_objects)
  end

  def find_by_name(district_name)
    @enrollment_objects.find do |enrollment|
      enrollment.name == district_name.upcase
    end
  end
end
