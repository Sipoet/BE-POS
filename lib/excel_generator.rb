class ExcelGenerator

  attr_reader :columns, :rows, :metadata

  def initialize
    @columns = []
    @rows = []
  end

  def add_column_definitions(column_definitions)
    raise 'column definitions is empty' if column_definitions.empty?
    raise 'not table column' if !column_definitions.first.is_a?(Datatable::TableColumn)
    @columns = column_definitions
  end

  def add_data(rows)
    @rows += rows
  end

  def add_footer(row)
    @footer = row
  end

  def add_metadata(metadata)
    @metadata = metadata
  end

  def generate(filename = 'data.xlsx')
    raise 'column definitions is empty' if columns.empty?
    tempfile = Tempfile.new([filename.split('.xlsx')[0],'.xlsx'])
    workbook = WriteXLSX.new(tempfile.path)
    add_format(workbook)
    generate_master_data(workbook)
    generate_metadata(workbook)
    workbook.close
    tempfile
  end

  private

  def add_format(workbook)
    @header_format = workbook.add_format(bold: true, size: 12)
    @num_format = workbook.add_format(size: 12, num_format: '#,##0.0')
    @general_format = workbook.add_format(size: 12)
    @date_format = workbook.add_format(size: 12, num_format: 'dd/mm/yyyy')
    @datetime_format = workbook.add_format(size: 12, num_format: 'dd/mm/yyyy hh:mm')
  end

  def generate_master_data(workbook)
    worksheet = workbook.add_worksheet('data')
    add_header(workbook, worksheet)
    rows.each.with_index(1) do |row, index_vertical|
      decorate_row(index_vertical,row,worksheet)
    end
  end

  def add_header(workbook, worksheet)
    worksheet.set_row(0, 16, @header_format)
    columns.each.with_index(0) do |column, index|
      worksheet.set_column(index, index, column.width)
      worksheet.write(0,index, column.humanize_name, @header_format)
    end
  end


  def decorate_row(y,row,worksheet)
    columns.each.with_index(0) do |column, x|
      value = row.try(column.name)
      if value.blank?
        next
      end
      case column.type
      when :integer,:float,:decimal,:big_decimal,:money
        worksheet.write_number(y, x, value.to_f, @num_format)
      when :percentage
        worksheet.write_number(y, x, value.to_f, @num_format)
      when :date
        worksheet.write_date_time(y, x, value.strftime('%d/%m/%Y'), @date_format)
      when :datetime, :time
        worksheet.write_date_time(y, x, value.strftime('%d/%m/%Y %H:%M'), @datetime_format)
      else
        worksheet.write_string(y, x, value.to_s, @general_format)
      end
    end
  end

  def generate_metadata(workbook)
    worksheet = workbook.add_worksheet('metadata')
    label_format = workbook.add_format(bold: true, align: 'right')
    datetime_format = workbook.add_format(num_format: 'dd mmmm yyyy hh:mm')
    filter_format = workbook.add_format(bold: true, align: 'right', size: 14)
    worksheet.set_column(0, 0, 20, label_format)
    worksheet.set_column(1, 1, 25)
    worksheet.set_column(3, 3, 20, label_format)
    worksheet.write_string(0, 0, 'Report generated at :')
    worksheet.write_date_time(0,1, DateTime.now.in_time_zone('Singapore').iso8601[0..18], datetime_format)
    @metadata.each.with_index(2) do |(key, value), index|
      worksheet.write_string(index, 0, "#{key} :")
      worksheet.write_string(index, 1, value.is_a?(Array) ? value.join(', ') : value.to_s)
    end
  end
end
