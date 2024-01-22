class ItemSale::PeriodReportService < BaseService

  def execute_service
    extract_params
    if !valid?
      render_json({message: @error_message},{status: :conflict})
      return
    end
    query = execute_sql(query_report)
    data = decorate_result(query)
    if @report_type == 'json'
      meta = {
        quantity_total: data.sum(&:quantity),
        sales_total: data.sum(&:sales_total),
        subtotal: data.sum(&:subtotal),
        discount_total: data.sum(&:discount_total),
        filter:{
          start_time: @start_time,
          end_time: @end_time,
          discount_code: @discount_code,
          suppliers: @suppliers,
          brands: @brands,
          items: @items,
          item_types: @item_types
        }
      }
      render_json(ItemSalesPeriodReportSerializer.new(data, {meta: meta}))
    elsif @report_type == 'xlsx'
      file_excel = generate_excel(data)
      @controller.send_file file_excel
    end
  end

  private

  def valid?
    @error_message = []
    if @start_time.blank? || @end_time.blank?
      @error_message << 'tanggal harus valid'
    elsif @start_time > @end_time
      @error_message << 'tanggal mulai harus lebih kecil dari tanggal sampai'
    end
    @error_message = @error_message.join(',')
    @error_message.blank?
  end

  def generate_excel(data)
    file = Tempfile.new([filename, '.xlsx'])
    workbook = WriteXLSX.new(file.path)
    insert_to_sheet_data(workbook, data)
    filter = {
      'Start time': @start_time,
      'End time': @end_time,
      'Discount code': @discount_code,
      'Suppliers': @suppliers,
      'Brands': @brands,
      'Items': @items,
      'Item types': @item_types
    }
    insert_metadata(workbook, filter)
    workbook.close
    file
  end

  def insert_to_sheet_data(workbook, data)
    worksheet = workbook.add_worksheet('data')
    add_header(workbook, worksheet)
    add_data(workbook, worksheet, data)
  end

  def insert_metadata(workbook, filter)
    worksheet = workbook.add_worksheet('metadata')
    label_format = workbook.add_format(bold: true, align: 'right')
    datetime_format = workbook.add_format(num_format: 'dd mmmm yyyy hh:mm')
    filter_format = workbook.add_format(bold: true, align: 'right', size: 14)
    worksheet.set_column(0, 0, 20, label_format)
    worksheet.set_column(1, 1, 25)
    worksheet.set_column(3, 3, 20, label_format)
    worksheet.write_string(0, 0, 'Report generated at :')
    worksheet.write_date_time('B1', DateTime.now.iso8601[0..18], datetime_format)
    worksheet.write_string(1, 0, 'FILTER', filter_format)
    index = 2
    filter.each do |key, value|
      worksheet.write_string(index, 0, "#{key} :")
      worksheet.write_string(index, 1, value.is_a?(Array) ? value.join(', ') : value.to_s)
      index += 1
    end
  end

  def add_header(workbook, worksheet)
    header_format = workbook.add_format(bold: true, size: 14)
    worksheet.set_row(0, 22, header_format)
    localized_column_names.each.with_index(0) do |header_name, index|
      worksheet.write(0,index, header_name, header_format)
    end
  end

  def localized_column_names
    ItemSalesPeriodReport::TABLE_HEADER.map { |column_name| ItemSalesPeriodReport.human_attribute_name(column_name) }
  end

  def add_data(workbook, worksheet, data)
    num_format = workbook.add_format(size: 12, num_format: '#,##0')
    general_format = workbook.add_format(size: 12)
    date_format = workbook.add_format(size: 12, num_format: 'dd/mm/yy')
    datetime_format = workbook.add_format(size: 12, num_format: 'dd/mm/yy hh:mm')
    worksheet.set_column(5, 11, 24, num_format)
    worksheet.set_column(0, 4, 17, general_format)
    worksheet.set_column(1, 1, 45)
    worksheet.set_column(9, 9, 20, general_format)
    data.each.with_index(1) do |row, index_vertical|
      ItemSalesPeriodReport::TABLE_HEADER.each.with_index(0) do |key, index|
        value = row.send(key)
        if value.nil?
          worksheet.write_blank(3, 0)
        elsif value.is_a?(Numeric)
          worksheet.write_number(index_vertical, index, value.to_f,num_format)
        elsif value.is_a?(Date)
          worksheet.write_date_time(index_vertical, index, value.iso8601,date_format)
        elsif value.respond_to?(:strftime)
          worksheet.write_date_time(index_vertical, index, value.iso8601,datetime_format)
        else
          worksheet.write_string(index_vertical, index, value.to_s,general_format)
        end
      end
    end
  end

  def filename
    'laporan-penjualan-item-periode'
  end

  def query_report
    <<~SQL
      SELECT
        #{Ipos::ItemSale.table_name}.kodeitem AS item_code,
        #{Ipos::Item.table_name}.namaitem AS item_name,
        #{Ipos::Item.table_name}.supplier1 AS supplier_code,
        #{Ipos::Item.table_name}.merek AS brand_name,
        #{Ipos::Item.table_name}.jenis AS item_type_name,
        #{Ipos::ItemSale.table_name}.potongan AS discount_percentage,
        #{Ipos::Item.table_name}.hargapokok AS buy_price,
        #{Ipos::Item.table_name}.hargajual1 AS sell_price,
        COALESCE(SUM(#{Ipos::ItemSale.table_name}.harga * #{Ipos::ItemSale.table_name}.jumlah),0) AS subtotal,
        SUM(#{Ipos::ItemSale.table_name}.jumlah) AS quantity,
        SUM(#{Ipos::ItemSale.table_name}.total) AS sales_total
      FROM #{Ipos::ItemSale.table_name}
      INNER JOIN #{Ipos::Sale.table_name} ON #{Ipos::Sale.table_name}.notransaksi  = #{Ipos::ItemSale.table_name}.notransaksi
      INNER JOIN #{Ipos::Item.table_name} ON #{Ipos::Item.table_name}.kodeitem  = #{Ipos::ItemSale.table_name}.kodeitem
      WHERE
        #{Ipos::Sale.table_name}.tanggal BETWEEN '#{@start_time}' AND '#{@end_time}'
        #{filter_query_suppliers}
        #{filter_query_item_types}
        #{filter_query_brands}
        #{filter_query_items}
        #{filter_query_discount}
      GROUP BY
        #{Ipos::ItemSale.table_name}.kodeitem,
        #{Ipos::Item.table_name}.namaitem,
        #{Ipos::Item.table_name}.supplier1,
        #{Ipos::Item.table_name}.merek,
        #{Ipos::Item.table_name}.jenis,
        #{Ipos::Item.table_name}.hargapokok,
        #{Ipos::Item.table_name}.hargajual1,
        #{Ipos::ItemSale.table_name}.potongan
      ORDER BY
        item_code ASC
    SQL
  end

  def filter_query_suppliers
    return if @suppliers.blank?
    return "AND #{ApplicationRecord.sanitize_sql(["#{Ipos::Item.table_name}.supplier1 in (?)",@suppliers])}"
  end

  def filter_query_item_types
    return if @item_types.blank?
    return "AND #{ApplicationRecord.sanitize_sql(["#{Ipos::Item.table_name}.jenis in (?)",@item_types])}"
  end

  def filter_query_brands
    return if @brands.blank?
    return "AND #{ApplicationRecord.sanitize_sql(["#{Ipos::Item.table_name}.merek in (?)",@brands])}"
  end

  def filter_query_items
    return if @items.blank?
    return "AND #{ApplicationRecord.sanitize_sql(["#{Ipos::Item.table_name}.kodeitem in (?)",@items])}"
  end

  def filter_query_discount
    return if @discount_code.blank?
    return "AND #{ApplicationRecord.sanitize_sql(["#{Ipos::Sale.table_name}.kode ilike '%?%'",@discount_code])}"
  end

  def decorate_result(query)
    query.to_a.map{ |row| ItemSalesPeriodReport.new(row)}
  end

  def extract_params
    @start_time = @params.fetch(:start_time,Time.now.utc.beginning_of_day).try(:to_time)
    @end_time = @params.fetch(:end_time,Time.now.utc.end_of_day).try(:to_time)
    @discount_code = @params[:discount_code]
    @suppliers = *@params[:suppliers]
    @brands = *@params[:brands]
    @items = *@params[:items]
    @item_types = *@params[:item_types]
    @report_type = @params[:report_type]
  end
end
