require_relative 'enrollment'
require_relative 'data_utilities'

class EnrollmentDataFormatter

  def read_enrollment_files(files)
    category = files[:enrollment]
    @kindergarten_contents = DataUtilities.open_csv(category[:kindergarten])
    if category[:high_school_graduation]
      @high_school_contents = DataUtilities.open_csv(category[:high_school_graduation])
    end
  end

  def load_enrollment_data(files, enrollment_objects)
    read_enrollment_files(files)
    @kindergarten_contents.each do |row|
      if DataUtilities.no_object_by_current_name(enrollment_objects, row)
        create_new_enrollment_object(enrollment_objects, row)
      end
      match_enrollment_data_to_district_data(enrollment_objects,
                                            :kindergarten_participation, row)
    end
    if @high_school_contents
      @high_school_contents.each do |row|
        match_enrollment_data_to_district_data(enrollment_objects,
                                              :high_school_graduation, row)
      end
    end
  end

  def match_enrollment_data_to_district_data(enrollment_objects, success, row)
    match = enrollment_objects.find do |enrollment|
      row[:location].upcase == enrollment.name.upcase
    end
    match.data[success][row[:timeframe].to_i] =
    DataUtilities.truncate_value(row[:data].to_f)
  end

  def create_new_enrollment_object(enrollment_objects, row)
    enrollment_objects << Enrollment.new({:name => row[:location].upcase,
                                          :kindergarten_participation => {},
                                          :high_school_graduation => {}})
  end
end
