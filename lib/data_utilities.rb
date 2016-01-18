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
      if district_objects.empty?
        district_objects << District.new({:name => row[:location]})
      elsif !district_objects.any? { |district_object| district_object.name == row[:location].upcase }
        district_objects << District.new({:name => row[:location]})
      end
    end
    if hash[:statewide_testing]
      @str = StatewideTestRepository.new
      @str.load_data(:statewide_testing => hash[:statewide_testing])
      district_objects.each do |district_object|
        @str.statewide_objects.each do |statewide_object|
          if statewide_object.data[:name].upcase == district_object.name
            district_object.statewide_test = StatewideTest.new(statewide_object.data)
          end
        end
      end
    end
    if hash[:economic_profile]
      @epr = EconomicProfileRepository.new
      @epr.load_data(:economic_profile => hash[:economic_profile])
      district_objects.each do |district_object|
        @epr.economic_profile_objects.each do |economic_profile_object|
          if economic_profile_object.data[:name].upcase == district_object.name.upcase
            district_object.economic_profile = EconomicProfile.new(economic_profile_object.data)
          end
        end
      end
    end
    @er = EnrollmentRepository.new
    if !hash[:enrollment][:high_school_graduation]
      @er.load_data(:enrollment => {:kindergarten => hash[:enrollment][:kindergarten]})
    else
      @er.load_data(:enrollment => hash[:enrollment])
    end
    district_objects.each do |district_object|
      @er.enrollment_objects.each do |enrollment_object|
        if enrollment_object.data[:name].upcase == district_object.name
          district_object.enrollment = Enrollment.new(enrollment_object.data)
        end
      end
    end
  end



  def self.load_testing_data(hash, statewide_objects)
    read_testing_files(hash)
    @third_grade_contents.each do |row|
      if statewide_objects.empty? || statewide_objects.none? { |statewide_object| statewide_object.name == row[:location] }
        create_new_statewide_object_hash(statewide_objects, row)
        add_data_to_existing_statewide_object(statewide_objects, row, :third_grade, :score)
      else
        if statewide_objects.any? { |statewide_object| statewide_object.name == row[:location] }
          add_data_to_existing_statewide_object(statewide_objects, row, :third_grade, :score)
        end
      end
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
    @mhi_contents.each do |row|
      if economic_profile_objects.empty?
        create_new_economic_profile_object(economic_profile_objects, row)
        economic_profile_objects.each do |economic_profile_object|
          if row[:location].upcase == economic_profile_object.name.upcase
            economic_profile_object.data[:median_household_income][row[:timeframe].split("-").map! { |year| year.to_i}] = row[:data].to_i
          end
        end
      end
      if economic_profile_objects.any? { |economic_profile_object| economic_profile_object.name.upcase == row[:location].upcase }
        economic_profile_objects.each do |economic_profile_object|
          if row[:location].upcase == economic_profile_object.name.upcase
            economic_profile_object.data[:median_household_income][row[:timeframe].split("-").map! { |year| year.to_i}] = row[:data].to_i
          end
        end
      else #only do this if NONE of them match the name, not just if the current one doesn't match the name
        create_new_economic_profile_object(economic_profile_objects, row)
        economic_profile_objects.each do |economic_profile_object|
          if row[:location].upcase == economic_profile_object.name.upcase
            economic_profile_object.data[:median_household_income][row[:timeframe].split("-").map! { |year| year.to_i}] = row[:data].to_i
          end
        end
      end
    end
    @cip_contents.each do |row|
      economic_profile_objects.each do |economic_profile_object|
        if row[:location].upcase == economic_profile_object.name.upcase
          if row[:dataformat] == "Percent"
            economic_profile_object.data[:children_in_poverty][row[:timeframe].to_i] = row[:data].to_f
          end
        end
      end
    end
    @frl_contents.each do |row|
      economic_profile_objects.each do |economic_profile_object|
        if row[:location].upcase == economic_profile_object.name.upcase
          if economic_profile_object.data[:free_or_reduced_price_lunch][row[:timeframe].to_i]
            if row[:poverty_level] == "Eligible for Free or Reduced Lunch"
              if row[:dataformat] == "Percent"
                economic_profile_object.data[:free_or_reduced_price_lunch][row[:timeframe].to_i][:percentage] = row[:data].to_f
              elsif row[:dataformat] == "Number"
                economic_profile_object.data[:free_or_reduced_price_lunch][row[:timeframe].to_i][:total] = row[:data].to_i
              end
            end
          else
            if row[:poverty_level] == "Eligible for Free or Reduced Lunch"
              if row[:dataformat] == "Percent"
                economic_profile_object.data[:free_or_reduced_price_lunch][row[:timeframe].to_i] = {:percentage => row[:data].to_f}
              elsif row[:dataformat] == "Number"
                economic_profile_object.data[:free_or_reduced_price_lunch][row[:timeframe].to_i] = {:total => row[:data].to_i}
              end
            end
          end
        end
      end
    end
    @ti_contents.each do |row|
      economic_profile_objects.each do |economic_profile_object|
        if row[:location].upcase == economic_profile_object.name.upcase
          economic_profile_object.data[:title_i][row[:timeframe].to_i] = row[:data].to_f
        end
      end
    end
  end

  def self.load_enrollment_data(hash, enrollment_objects)
    read_enrollment_files(hash)
    @kindergarten_contents.each do |row|
      if enrollment_objects.empty?
        create_new_enrollment_object(enrollment_objects, row)
        enrollment_objects.each do |enrollment_object|
          if row[:location].upcase == enrollment_object.name.upcase
            enrollment_object.data[:kindergarten_participation][row[:timeframe].to_i] = row[:data].to_f
          end
        end
      else
        enrollment_objects.each do |enrollment_object|
          if enrollment_objects.any? { |enrollment_object| enrollment_object.name.upcase == row[:location].upcase }
            if row[:location].upcase == enrollment_object.name.upcase
              enrollment_object.data[:kindergarten_participation][row[:timeframe].to_i] = row[:data].to_f
            end
          else
            create_new_enrollment_object(enrollment_objects, row)
            if row[:location].upcase == enrollment_object.name.upcase
              enrollment_object.data[:kindergarten_participation][row[:timeframe].to_i] = row[:data].to_f
            end
          end
        end
      end
    end
    if @high_school_contents
      @high_school_contents.each do |row|
        enrollment_objects.each do |enrollment_object|
          if row[:location].upcase == enrollment_object.name.upcase
            enrollment_object.data[:high_school_graduation][row[:timeframe].to_i] = row[:data].to_f
          end
        end
      end
    end
  end

  def self.add_data_to_existing_statewide_object(statewide_objects, row, data_type, delimeter)
    statewide_objects.each do |statewide_object|
      if row[:location] == statewide_object.name
        if statewide_object.data[data_type][row[:timeframe].to_i]
          if row[:data] == "N/A"
            statewide_object.data[data_type][row[:timeframe].to_i][row[delimeter].gsub(/\W/, "_").downcase.to_sym] = row[:data]
          else
            statewide_object.data[data_type][row[:timeframe].to_i][row[delimeter].gsub(/\W/, "_").downcase.to_sym] = row[:data].to_f
          end
        else
          if row[:data] == "N/A"
            statewide_object.data[data_type][row[:timeframe].to_i] = {row[delimeter].gsub(/\W/, "_").downcase.to_sym => row[:data]}
          else
            statewide_object.data[data_type][row[:timeframe].to_i] = {row[delimeter].gsub(/\W/, "_").downcase.to_sym => row[:data].to_f}
          end
        end
      end
    end
  end

  def self.create_new_enrollment_object(enrollment_objects, row)
    enrollment_objects << Enrollment.new({:name => row[:location].upcase,
    :kindergarten_participation => {},
    :high_school_graduation => {}})
  end

  def self.create_new_economic_profile_object(economic_profile_objects, row)
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
