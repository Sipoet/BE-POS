class ItemSalesPercentageReport::GroupBySupplierService < ApplicationService

  def execute_service
    extract_params
    results = execute_sql(query_sql)
    data = decorate_result(results)
    if @report_type == 'json'
      meta = {
        filter:{
          suppliers: @suppliers,
          brands: @brands,
          item_types: @item_types
        }
      }
      render_json(SalesGroupBySupplierReportSerializer.new(data, {meta: meta}))
    elsif @report_type == 'xlsx'
      file_excel = generate_excel(data)
      @controller.send_file file_excel.path
    end
  end

  private

  def extract_params
    permitted_params = @params.permit(:report_type,suppliers:[],brands:[],item_types:[])
    @suppliers = *permitted_params[:suppliers]
    @brands = *permitted_params[:brands]
    @items = *permitted_params[:items]
    @item_types = *permitted_params[:item_types]
    @report_type = permitted_params[:report_type]
  end

  def generate_excel(data)
    generator = ExcelGenerator.new
    generator.add_column_definitions(SalesGroupBySupplierReport::TABLE_HEADER)
    generator.add_data(data)
    generator.add_metadata({
      suppliers: @suppliers,
      brands: @brands,
      item_types: @item_types
    })
    generator.generate('laporan-penjualan-per-supplier')
  end

  def decorate_result(results)
    results.to_a.map{|row| SalesGroupBySupplierReport.new(row)}
  end

  def query_sql
    <<~SQL
      SELECT
        supplier_code,
        supplier_name,
        item_type_name,
        brand_name,
        ROUND(SUM(number_of_purchase),0) AS number_of_purchase,
        ROUND(SUM(number_of_sales),0) AS number_of_sales,
        ROUND(SUM(sales_total),0) AS sales_total,
        ROUND(SUM(purchase_total),0) AS purchase_total,
        ROUND(SUM(gross_profit),0) AS gross_profit
      FROM item_sales_percentage_reports
      WHERE
        #{filter_query}
      GROUP BY
        supplier_code,
        supplier_name,
        item_type_name,
        brand_name
      ORDER BY
        supplier_code asc,
        item_type_name asc,
        brand_name asc
    SQL
  end

  def filter_query
    [
      filter_query_suppliers,
      filter_query_item_types,
      filter_query_brands
  ].compact
  .join(' AND ')
  end

  def filter_query_suppliers
    return if @suppliers.blank?
    return "#{ApplicationRecord.sanitize_sql(["#{ItemSalesPercentageReport.table_name}.supplier_code in (?)",@suppliers])}"
  end

  def filter_query_item_types
    return if @item_types.blank?
    return "#{ApplicationRecord.sanitize_sql(["#{ItemSalesPercentageReport.table_name}.item_type_name in (?)",@item_types])}"
  end

  def filter_query_brands
    return if @brands.blank?
    return "#{ApplicationRecord.sanitize_sql(["#{ItemSalesPercentageReport.table_name}.brand_name in (?)",@brands])}"
  end
end
