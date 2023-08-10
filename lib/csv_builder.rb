class CsvBuilder
  require 'csv'
  attr_accessor :output, :header, :data

  def initialize(header, data, output = "")
    @output = output
    @header = header
    @data = data
  end

  def build
    output << CSV.generate_line(header)
    data.each do |row|
      output << CSV.generate_line(row)
    end
    output
  end
end