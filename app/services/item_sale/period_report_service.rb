class ItemSale::PeriodReportService < ApplicationService

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
      @controller.send_file file_excel.path
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
    filter = {
      'Start time': @start_time,
      'End time': @end_time,
      'Discount code': @discount_code,
      'Suppliers': @suppliers,
      'Brands': @brands,
      'Items': @items,
      'Item types': @item_types
    }
    generator = ExcelGenerator.new
    generator.add_column_definitions(ItemSalesPeriodReport::TABLE_HEADER)
    generator.add_data(data)
    generator.add_metadata(filter)
    generator.generate(filename)
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
        #{Ipos::Sale.table_name}.tipe IN('KSR','JL') AND
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
    permitted_params = @params.permit(:start_time,:end_time,:discount_code,:report_type,suppliers:[],brands:[],item_types:[],items:[])
    @start_time = permitted_params.fetch(:start_time,Time.now.utc.beginning_of_day).try(:to_time)
    @end_time = permitted_params.fetch(:end_time,Time.now.utc.end_of_day).try(:to_time)
    @discount_code = permitted_params[:discount_code]
    @suppliers = *permitted_params[:suppliers]
    @brands = *permitted_params[:brands]
    @items = *permitted_params[:items]
    @item_types = *permitted_params[:item_types]
    @report_type = permitted_params[:report_type]
  end
end
