class DataUtilities
  def self.truncate_value(value)
    (sprintf "%.3f", value).to_f
  end

  def self.open_csv(file)
    CSV.open file, headers: true, header_converters: :symbol
  end

  def self.read_economic_files(hash)
    @mhi_contents = open_csv(hash[:economic_profile][:median_household_income])
    @cip_contents = open_csv(hash[:economic_profile][:children_in_poverty])
    @frl_contents = open_csv(hash[:economic_profile][:free_or_reduced_price_lunch])
    @ti_contents = open_csv(hash[:economic_profile][:title_i])
  end

  def self.read_testing_files(hash)
    @third_grade_contents = open_csv(hash[:statewide_testing][:third_grade])
    @eighth_grade_contents = open_csv(hash[:statewide_testing][:eighth_grade])
    @math_contents = open_csv(hash[:statewide_testing][:math])
    @reading_contents = open_csv(hash[:statewide_testing][:reading])
    @writing_contents = open_csv(hash[:statewide_testing][:writing])
  end

  def self.load_testing_data(hash, statewide_objects)
    read_testing_files(hash)
    @third_grade_contents.each do |row|
      if statewide_objects.empty?
        create_new_statewide_object_hash(statewide_objects, row)
        add_data_to_existing_statewide_object(statewide_objects, row, :third_grade, :score)
      else
          if statewide_objects.any? { |statewide_object| statewide_object.name == row[:location] }
            add_data_to_existing_statewide_object(statewide_objects, row, :third_grade, :score)
          else #only do this if NONE of them match the name
            create_new_statewide_object_hash(statewide_objects, row)
            add_data_to_existing_statewide_object(statewide_objects, row, :third_grade, :score)
          end
      end
    end
    @eighth_grade_contents.each do |row|
      add_data_to_existing_statewide_object(statewide_objects, row, :eighth_grade, :score)
    end
    @math_contents.each do |row|
      add_data_to_existing_statewide_object(statewide_objects, row, :math, :race_ethnicity)
    end
    @reading_contents.each do |row|
      add_data_to_existing_statewide_object(statewide_objects, row, :reading, :race_ethnicity)
    end
    @writing_contents.each do |row|
      add_data_to_existing_statewide_object(statewide_objects, row, :writing, :race_ethnicity)
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

  def self.create_new_statewide_object_hash(statewide_objects, row)
    statewide_objects << StatewideTest.new({:name => row[:location],
    :third_grade => {},
    :eighth_grade => {},
    :math => {},
    :reading => {},
    :writing => {}})
  end

  def self.load_economic_data(hash, economic_profile_objects)
    read_economic_files(hash)
    @mhi_contents.each do |row|
      if economic_profile_objects.empty?
        economic_profile_objects << EconomicProfile.new({:name => row[:location].upcase,
        :median_household_income => {},
        :children_in_poverty => {},
        :free_or_reduced_price_lunch => {},
        :title_i => {}})
        economic_profile_objects.each do |economic_profile_object|
          if row[:location].upcase == economic_profile_object.name.upcase
            economic_profile_object.data[:median_household_income][row[:timeframe].split("-").map! { |year| year.to_i}] = row[:data].to_i
          end
        end
      end
      @mhi_contents.each do |row|
        if economic_profile_objects.any? { |economic_profile_object| economic_profile_object.name.upcase == row[:location].upcase }
          economic_profile_objects.each do |economic_profile_object|
            if row[:location].upcase == economic_profile_object.name.upcase
              economic_profile_object.data[:median_household_income][row[:timeframe].split("-").map! { |year| year.to_i}] = row[:data].to_i
            end
          end
        else #only do this if NONE of them match the name, not just if the current one doesn't match the name
          economic_profile_objects << EconomicProfile.new({:name => row[:location],
          :median_household_income => {},
          :children_in_poverty => {},
          :free_or_reduced_price_lunch => {},
          :title_i => {}})
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
  end
end
