require_relative 'enrollment'
require 'csv'

class EnrollmentRepository

  attr_reader :enrollment_objects

  def initialize
    @enrollment_objects = []
  end

  def load_data(hash)
    read_file(hash)
    @kindergarten_contents.each do |row|
      if enrollment_objects.empty?
        enrollment_objects << Enrollment.new({:name => row[:location].upcase,
        :kindergarten_participation => {},
        :high_school_graduation => {}})
        enrollment_objects.each do |enrollment_object|
          if row[:location].upcase == enrollment_object.name.upcase
            enrollment_object.data[:kindergarten_participation][row[:timeframe].to_i] = row[:data].to_f
          end
        end
      else
        # @kindergarten_contents.each do |row| TAKE THIS OUT!!!!!!!
          enrollment_objects.each do |enrollment_object|
            if enrollment_objects.any? { |enrollment_object| enrollment_object.name.upcase == row[:location].upcase }
              if row[:location].upcase == enrollment_object.name.upcase
                enrollment_object.data[:kindergarten_participation][row[:timeframe].to_i] = row[:data].to_f
              end
            else
              enrollment_objects << Enrollment.new({:name => row[:location],
              :kindergarten_participation => {},
              :high_school_graduation => {}})
              if row[:location].upcase == enrollment_object.name.upcase
                enrollment_object.data[:kindergarten_participation][row[:timeframe].to_i] = row[:data].to_f
              end
            end
          end
        # end
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

  def read_file(hash)
    hash.each do |category, path|
      @category = hash[category]
    end
    @kindergarten = @category[:kindergarten]
    @kindergarten_contents = CSV.open @kindergarten, headers: true, header_converters: :symbol
    if hash[:enrollment][:high_school_graduation]
      @hs_graduation = @category[:high_school_graduation]
      @high_school_contents = CSV.open @hs_graduation, headers: true, header_converters: :symbol
    end
  end

  def find_by_name(name)
    @enrollment_objects.select do |enrollment_object|
      if enrollment_object.data[:name] == name.upcase
        return enrollment_object
      end
    end
  end
end
