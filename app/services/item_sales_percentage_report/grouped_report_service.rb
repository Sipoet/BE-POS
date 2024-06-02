class ItemSalesPercentageReport::GroupedReportService < ApplicationService

  WHITELIST_GROUP = [:brand_name,:supplier_name,:item_type_name].freeze

  def execute_service
    extract_params
    if @group_names.empty?
      render_json({message:'group by harus diisi'},{status: :conflict})
    end
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
    permitted_params = @params.permit(:report_type,suppliers:[],
                                      brands:[],item_types:[],
                                      group_names:[])
    @suppliers = *permitted_params[:suppliers]
    @brands = *permitted_params[:brands]
    @items = *permitted_params[:items]
    @item_types = *permitted_params[:item_types]
    @report_type = permitted_params[:report_type]
    @group_names = *permitted_params[:group_names].map(&:to_sym) & WHITELIST_GROUP
  end

  def generate_excel(data)
    generator = ExcelGenerator.new
    table_headers = SalesGroupBySupplierReport::TABLE_HEADER.dup
    excluded_list = WHITELIST_GROUP.dup - @group_names
    table_headers.reject!{|table_def| excluded_list.include?(table_def.name)}
    sep_index = 0
    table_headers = table_headers.sort_by do|table_def|
      index = @group_names.index(table_def.name)
      if index.nil?
        sep_index+=1
        @group_names.length + sep_index
      else
        index
      end
    end
    Rails.logger.info "======#{table_headers.map(&:name)} =============== #{@group_names} ==== #{excluded_list}"
    generator.add_column_definitions(table_headers)
    generator.add_data(data)
    generator.add_metadata({
      suppliers: @suppliers,
      brands: @brands,
      item_types: @item_types
    })
    generator.generate('laporan-penjualan-per-supplier')
  end

  def decorate_result(results)
    results.to_a.map{|row|SalesGroupBySupplierReport.new(row)}
  end

  def query_sql
    <<~SQL
      SELECT
        #{@group_names.join(',')},
        ROUND(SUM(number_of_purchase),0) AS number_of_purchase,
        ROUND(SUM(number_of_sales),0) AS number_of_sales,
        ROUND(SUM(sales_total),0) AS sales_total,
        ROUND(SUM(purchase_total),0) AS purchase_total,
        ROUND(SUM(gross_profit),0) AS gross_profit
      FROM item_sales_percentage_reports
        #{filter_query}
      GROUP BY
        #{@group_names.join(',')}
      ORDER BY
        #{order_query}
    SQL
  end

  def order_query
    @group_names.map{|column_name|"#{column_name} ASC"}.join(',')
  end

  def filter_query
    query = [
      filter_query_suppliers,
      filter_query_item_types,
      filter_query_brands
    ].compact

    return '' if query.empty?
    "WHERE #{query.join(' AND ')}"
  end

  def filter_query_suppliers
    return if @suppliers.blank?
    return "#{ApplicationRecord.sanitize_sql(["#{ItemSalesPercentageReport.table_name}.supplier_code in (?)",@suppliers])}"
  end

  def filter_query_item_types
    return if @item_types.blank?
    return "#{ApplicationRecord.sanitize_sql(["#{ItemSalesPercentageReport.table_name}.item_type in (?)",@item_types])}"
  end

  def filter_query_brands
    return if @brands.blank?
    return "#{ApplicationRecord.sanitize_sql(["#{ItemSalesPercentageReport.table_name}.brand in (?)",@brands])}"
  end

end
