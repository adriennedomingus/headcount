require 'csv'

class DataUtilities
  def self.truncate_value(value)
    (sprintf "%.3f", value).to_f
  end

  def self.open_csv(file)
    CSV.open file, headers: true, header_converters: :symbol
  end

  def self.no_object_by_current_name(type_of_object, row)
    type_of_object.empty? || type_of_object.none? do |object|
      object.name == row[:location].upcase
    end
  end
end
