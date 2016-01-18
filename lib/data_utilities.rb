class DataUtilities
  def self.truncate_value(value)
    (sprintf "%.3f", value).to_f
  end

  def self.open_csv(file)
    CSV.open file, headers: true, header_converters: :symbol
  end

  def self.read_enrollment_files(hash)
    category = hash[:enrollment]
    @kindergarten_contents = open_csv(category[:kindergarten])
    if category[:high_school_graduation]
      @high_school_contents = open_csv(category[:high_school_graduation])
    end
  end

  def self.read_economic_files(hash)
    category = hash[:economic_profile]
    @mhi_contents = open_csv(category[:median_household_income])
    @cip_contents = open_csv(category[:children_in_poverty])
    @frl_contents = open_csv(category[:free_or_reduced_price_lunch])
    @ti_contents = open_csv(category[:title_i])
  end

  def self.read_district_files(hash)
    @contents = open_csv( "./data/Kindergartners in full-day program.csv")
  end

  def self.read_testing_files(hash)
    category = hash[:statewide_testing]
    @third_grade_contents = open_csv(category[:third_grade])
    @eighth_grade_contents = open_csv(category[:eighth_grade])
    @math_contents = open_csv(category[:math])
    @reading_contents = open_csv(category[:reading])
    @writing_contents = open_csv(category[:writing])
  end

  def self.load_all_data(hash, district_objects)
    read_district_files(hash)
    @contents.each do |row|
      if no_preexisting_object_by_current_name(district_objects, row)
        district_objects << District.new({:name => row[:location]})
      end
    end
    if hash[:statewide_testing]
      create_new_statewide_testing_objects(hash, district_objects)
    end
    if hash[:economic_profile]
      create_new_economic_profile_objects(hash, district_objects)
    end
    create_new_enrollment_repository(hash)
    match_enrollment_objects_to_district_object(district_objects)
  end

  def self.no_preexisting_object_by_current_name(type_of_object, row)
    type_of_object.empty? || type_of_object.none? do |object|
      object.name == row[:location].upcase
    end
  end

  def self.create_new_enrollment_repository(hash)
    @er = EnrollmentRepository.new
    if !hash[:enrollment][:high_school_graduation]
      @er.load_data(:enrollment =>
                   {:kindergarten => hash[:enrollment][:kindergarten]})
    else
      @er.load_data(:enrollment => hash[:enrollment])
    end
  end

  def self.match_enrollment_objects_to_district_object(district_objects)
    district_objects.each do |district|
      match = @er.enrollment_objects.find do |enrollment|
        enrollment.data[:name].upcase == district.name
      end
      district.enrollment = Enrollment.new(match.data)
    end
  end

  def self.create_new_statewide_testing_objects(hash, district_objects)
    @str = StatewideTestRepository.new
    @str.load_data(:statewide_testing => hash[:statewide_testing])
    district_objects.each do |district|
      match = @str.statewide_objects.find do |statewide|
        statewide.data[:name].upcase == district.name
      end
      district.statewide_test = StatewideTest.new(match.data)
    end
  end

  def self.create_new_economic_profile_objects(hash, district_objects)
    @epr = EconomicProfileRepository.new
    @epr.load_data(:economic_profile => hash[:economic_profile])
    district_objects.each do |district|
      match = @epr.economic_profile_objects.find do |economic_profile|
        economic_profile.data[:name].upcase == district.name.upcase
      end
      district.economic_profile = EconomicProfile.new(match.data)
    end
  end

  def self.load_testing_data(hash, statewide_objects)
    read_testing_files(hash)
    @third_grade_contents.each do |row|
      if no_preexisting_object_by_current_name(statewide_objects, row)
        create_new_statewide_object_hash(statewide_objects, row)
      end
      statewide_objects.find { |statewide| statewide.name == row[:location] }
      add_data_to_existing_statewide_object(statewide_objects, row, :third_grade, :score)
    end
    @eighth_grade_contents.each do |row|
      add_data_to_existing_statewide_object(statewide_objects, row, :eighth_grade, :score)
    end
    load_subject_data(statewide_objects)
  end

  def self.load_subject_data(statewide_objects)
    contents_hash = {math: @math_contents,
      reading: @reading_contents,
      writing: @writing_contents}
    contents_hash.each do |subject, contents|
      contents.each do |row|
        add_data_to_existing_statewide_object(statewide_objects, row, subject, :race_ethnicity)
      end
    end
  end

  def self.load_economic_data(hash, economic_profile_objects)
    read_economic_files(hash)
    load_median_household_income_data(economic_profile_objects)
    load_children_in_poverty_data(economic_profile_objects)
    load_frl_data(economic_profile_objects)
    load_title_i_data(economic_profile_objects)
  end

  def self.load_median_household_income_data(economic_profile_objects)
    @mhi_contents.each do |row|
      if no_preexisting_object_by_current_name(economic_profile_objects, row)
        create_new_economic_profile_object_hash(economic_profile_objects, row)
      end
      match = economic_profile_objects.find do |economic_profile|
        row[:location].upcase == economic_profile.name.upcase
      end
      year = row[:timeframe].split("-").map! { |year| year.to_i}
      match.data[:median_household_income][year] = row[:data].to_i
    end
  end

  def self.load_children_in_poverty_data(economic_profile_objects)
    @cip_contents.each do |row|
      next unless row[:dataformat] == "Percent"
      matching_epo = economic_profile_objects.find { |economic_profile| row[:location].upcase == economic_profile.name.upcase }
      matching_epo.data[:children_in_poverty][row[:timeframe].to_i] = row[:data].to_f
    end
  end

  def self.load_frl_data(economic_profile_objects)
    @frl_contents.each do |row|
      next unless row[:poverty_level] == "Eligible for Free or Reduced Lunch"
      matching_epo = economic_profile_objects.find do |economic_profile|
        row[:location].upcase == economic_profile.name.upcase
      end
      if row[:dataformat] == "Percent"
        matching_epo.set_free_or_reduced_price_lunch_percentage(row[:timeframe].to_i, row[:data].to_f)
      elsif row[:dataformat] == "Number"
        matching_epo.set_free_or_reduced_price_lunch_total(row[:timeframe].to_i, row[:data].to_i)
      end
    end
  end

  def self.load_title_i_data(economic_profile_objects)
    @ti_contents.each do |row|
      match = economic_profile_objects.find do |economic_profile|
        row[:location].upcase == economic_profile.name.upcase
      end
      match.data[:title_i][row[:timeframe].to_i] = row[:data].to_f
    end
  end

  def self.load_enrollment_data(hash, enrollment_objects)
    read_enrollment_files(hash)
    @kindergarten_contents.each do |row|
      if no_preexisting_object_by_current_name(enrollment_objects, row)
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
        enrollment.data[success][row[:timeframe].to_i] = row[:data].to_f
      end
    end
  end

  def self.add_data_to_existing_statewide_object(statewide_objects, row, data_type, delimeter)
    subject = row[delimeter].gsub(/\W/, "_").downcase.to_sym
    statewide_objects.each do |statewide|
      if row[:location] == statewide.name
        statewide.data[data_type][row[:timeframe].to_i] ||= {}
        if row[:data] == "N/A"
          statewide.data[data_type][row[:timeframe].to_i][subject] = row[:data]
        else
          statewide.data[data_type][row[:timeframe].to_i][subject] = row[:data].to_f
        end
      end
    end
  end

  def self.create_new_enrollment_object(enrollment_objects, row)
    enrollment_objects << Enrollment.new({:name => row[:location].upcase,
    :kindergarten_participation => {},
    :high_school_graduation => {}})
  end

  def self.create_new_economic_profile_object_hash(economic_profile_objects, row)
    economic_profile_objects << EconomicProfile.new({:name => row[:location].upcase,
    :median_household_income => {},
    :children_in_poverty => {},
    :free_or_reduced_price_lunch => {},
    :title_i => {}})
  end

  def self.create_new_statewide_object_hash(statewide_objects, row)
    statewide_objects << StatewideTest.new({:name => row[:location],
    :third_grade => {},
    :eighth_grade => {},
    :math => {},
    :reading => {},
    :writing => {}})
  end
end
