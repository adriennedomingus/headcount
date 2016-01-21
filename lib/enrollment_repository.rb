require_relative 'enrollment_data_formatter'

class EnrollmentRepository
  attr_reader :enrollment_objects

  def initialize(enrollment_objects = [])
    @enrollment_objects = enrollment_objects
    @formatter = EnrollmentDataFormatter.new
  end

  def load_data(files)
    @formatter.load_enrollment_data(files, enrollment_objects)
  end

  def find_by_name(district_name)
    @enrollment_objects.find do |enrollment|
      enrollment.name == district_name.upcase
    end
  end
end
