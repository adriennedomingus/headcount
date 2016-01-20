require_relative 'data_utilities'
require_relative 'economic_profile'

class EconomicDataFormatter

  def self.read_economic_files(hash)
    category = hash[:economic_profile]
    @mhi_contents = DataUtilities.open_csv(category[:median_household_income])
    @cip_contents = DataUtilities.open_csv(category[:children_in_poverty])
    @frl_contents = DataUtilities.open_csv(category[:free_or_reduced_price_lunch])
    @ti_contents = DataUtilities.open_csv(category[:title_i])
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
      if DataUtilities.no_preexisting_object_by_current_name(economic_profile_objects, row)
        create_new_economic_profile_object_hash(economic_profile_objects, row)
      end
      match = economic_profile_objects.find do |economic_profile|
        row[:location].upcase == economic_profile.name.upcase
      end
      year = row[:timeframe].split("-").map! { |timeframe| timeframe.to_i}
      match.data[:median_household_income][year] = row[:data].to_i
    end
  end

  def self.load_children_in_poverty_data(economic_profile_objects)
    @cip_contents.each do |row|
      next unless row[:dataformat] == "Percent"
      matching_epo = economic_profile_objects.find do |economic_profile|
        row[:location].upcase == economic_profile.name.upcase
      end
      matching_epo.data[:children_in_poverty][row[:timeframe].to_i] = DataUtilities.truncate_value(row[:data].to_f)
    end
  end

  def self.load_frl_data(economic_profile_objects)
    @frl_contents.each do |row|
      next unless row[:poverty_level] == "Eligible for Free or Reduced Lunch"
      matching_epo = economic_profile_objects.find do |economic_profile|
        row[:location].upcase == economic_profile.name.upcase
      end
      case row[:dataformat]
      when "Percent"
        matching_epo.set_free_or_reduced_price_lunch_percentage(row[:timeframe].to_i, DataUtilities.truncate_value(row[:data].to_f))
      when "Number"
        matching_epo.set_free_or_reduced_price_lunch_total(row[:timeframe].to_i, row[:data].to_i)
      else
        next
      end
    end
  end

  def self.load_title_i_data(economic_profile_objects)
    @ti_contents.each do |row|
      match = economic_profile_objects.find do |economic_profile|
        row[:location].upcase == economic_profile.name.upcase
      end
      match.data[:title_i][row[:timeframe].to_i] = DataUtilities.truncate_value(row[:data].to_f)
    end
  end

  def self.create_new_economic_profile_object_hash(economic_profile_objects, row)
    economic_profile_objects << EconomicProfile.new({:name => row[:location].upcase,
    :median_household_income => {},
    :children_in_poverty => {},
    :free_or_reduced_price_lunch => {},
    :title_i => {}})
  end
end
