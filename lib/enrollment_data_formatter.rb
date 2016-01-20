require 'csv'
require_relative 'data_utilities'

class EnrollmentDataFormatter

  def self.read_enrollment_files(hash)
    category = hash[:enrollment]
    @kindergarten_contents = DataUtilities.open_csv(category[:kindergarten])
    if category[:high_school_graduation]
      @high_school_contents = DataUtilities.open_csv(category[:high_school_graduation])
    end
  end

  def self.load_enrollment_data(hash, enrollment_objects)
    read_enrollment_files(hash)
    @kindergarten_contents.each do |row|
      if DataUtilities.no_preexisting_object_by_current_name(enrollment_objects, row)
        create_new_enrollment_object(enrollment_objects, row)
      end
      match_enrollment_data_to_district_data(enrollment_objects, :kindergarten_participation, row)
    end
    if @high_school_contents
      @high_school_contents.each do |row|
        match_enrollment_data_to_district_data(enrollment_objects, :high_school_graduation, row)
      end
    end
  end

  def self.match_enrollment_data_to_district_data(enrollment_objects, success, row)
    enrollment_objects.each do |enrollment|
      if row[:location].upcase == enrollment.name.upcase
        enrollment.data[success][row[:timeframe].to_i] = DataUtilities.truncate_value(row[:data].to_f)
      end
    end
  end

  def self.create_new_enrollment_object(enrollment_objects, row)
    enrollment_objects << Enrollment.new({:name => row[:location].upcase,
    :kindergarten_participation => {},
    :high_school_graduation => {}})
  end

end
