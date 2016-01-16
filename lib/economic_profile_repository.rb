require 'csv'
require_relative 'economic_profile'

class EconomicProfileRepository
  attr_reader :economic_profile_objects, :data

  def initialize
    @economic_profile_objects = []
  end

  def read_file(hash)
    hash.each do |category, path|
      @category = hash[category]
    end
    @median_household_income = @category[:median_household_income]
    @mhi_contents = CSV.open @median_household_income, headers: true, header_converters: :symbol
    @children_in_poverty = @category[:children_in_poverty]
    @cip_contents = CSV.open @children_in_poverty, headers: true, header_converters: :symbol
    @free_or_reduced_price_lunch = @category[:free_or_reduced_price_lunch]
    @frl_contents = CSV.open @free_or_reduced_price_lunch, headers: true, header_converters: :symbol
    @title_i = @category[:title_i]
    @ti_contents = CSV.open @title_i, headers: true, header_converters: :symbol
  end

  def load_data(hash)
    read_file(hash)
    @mhi_contents.each do |row|
      if economic_profile_objects.empty?
        economic_profile_objects << EconomicProfile.new({:name => row[:location],
        :median_household_income => {},
        :children_in_poverty => {},
        :free_or_reduced_price_lunch => {:percentage => {}, :total => {}},
        :title_i => {}})
      else
        @mhi_contents.each do |row|
          if economic_profile_objects.any? { |economic_profile_object| economic_profile_object.name == row[:location] }
            economic_profile_objects.each do |economic_profile_object|
              if row[:location] == economic_profile_object.name
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
              if row[:location] == economic_profile_object.name
                economic_profile_object.data[:median_household_income][row[:timeframe].split("-").map! { |year| year.to_i}] = row[:data].to_i
              end
            end
          end
        end
        @cip_contents.each do |row|
          economic_profile_objects.each do |economic_profile_object|
            if row[:location] == economic_profile_object.name
              economic_profile_object.data[:children_in_poverty][row[:timeframe].to_i] = row[:data].to_f
            end
          end
        end
        @frl_contents.each do |row|
          economic_profile_objects.each do |economic_profile_object|
            if row[:location] == economic_profile_object.name
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
            if row[:location] == economic_profile_object.name
              economic_profile_object.data[:title_i][row[:timeframe].to_i] = row[:data].to_f
            end
          end
        end
      end
    end
  end

  def find_by_name(name)
    economic_profile_objects.select do |economic_profile|
      if name.upcase == economic_profile.data[:name].upcase
        return economic_profile
      end
    end
  end
end
