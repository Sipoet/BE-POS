class ItemSalesPerformanceReport::SupplierService < ApplicationService

  def execute_service
    extract_params
    extract_date_range
    reports = find_reports
    identifier_list = get_identifiers(reports)
    grouped_report = group_by_supplier(reports,identifier_list)
    render_json({
      data: grouped_report,
      metadata: {
        start_date: @start_date,
        end_date: @end_date,
        identifier_list: identifier_list,
        brand_names: @brand_names,
        item_type_names: @item_type_names
      },
    })
  end

  private

  def find_reports
    query = @base_query.order(supplier_code: :asc)
    if @supplier_codes.any?
      query = query.where(supplier_code: @supplier_codes)
    end
    if @brand_names.any?
      query = query.where(brand_name: @brand_names)
    end
    if @item_type_names.any?
      query = query.where(item_type_name: @item_type_names)
    end
    group_field = [:supplier_code, @id_field_name]
    if @separate_purchase_year
      group_field << :last_purchase_year
    end
    query.group(group_field)
         .sum(@value_type)
         .map do |keys,value|
            QueryResult.new(
              supplier_code: keys[0],
              last_purchase_year: keys[2],
              value: value,
              date_pk: keys[1])
         end

  end

  def get_identifiers(reports)
    reports.map(&:date_pk).uniq
  end

  def group_by_supplier(reports,identifier_list)
    suppliers = Ipos::Supplier.where(code: @supplier_codes).index_by(&:code)
    reports.group_by{|row|[row.supplier_code, row.last_purchase_year].compact}
           .map do |keys,values|
              row = LineResult.new(supplier_code: keys[0], last_purchase_year: keys[1])
              value_hash = values.index_by(&:date_pk)
              identifier_list.each do |date_pk|
                row.add_spot([date_pk, value_hash[date_pk]&.value || 0.0])
              end
              row.supplier_name = suppliers[row.supplier_code]&.name
              row
           end
  end

  class QueryResult
    attr_accessor :supplier_code, :last_purchase_year, :date_pk, :value

    def initialize(supplier_code:,last_purchase_year: nil,value:,date_pk:)
      @supplier_code = supplier_code
      @last_purchase_year = last_purchase_year
      @date_pk = date_pk
      @value = value.to_f
    end

  end

  class LineResult
    attr_accessor :supplier_code, :supplier_name, :last_purchase_year, :spots

    def initialize(supplier_code:,last_purchase_year: nil, spots:[])
      @supplier_code = supplier_code
      @last_purchase_year = last_purchase_year
      @spots = spots
    end

    def add_spot(spot)
      @spots << spot
    end

  end

  def extract_date_range
    @end_date = Date.yesterday.end_of_day
    @id_field_name = :date_pk
    if @period == 'day'
      @start_date = @start_date.beginning_of_day
      @end_date = Date.today.end_of_day
      @base_query = ItemSalesPerformanceReport.where(date_pk: @start_date..@end_date)
                                              .joins(:item)
      @group_period_field
    elsif @period == 'week'
      @start_date = Date.today - 6.days
      @base_query = DaySalesPerformanceReport.where(date_pk: @start_date..@end_date)
    elsif @period == 'month'
      @start_date = Date.today - 30.days
      @base_query = DaySalesPerformanceReport.where(date_pk: @start_date..@end_date)
    elsif @period == 'year'
      @start_date = Date.tomorrow - 1.year
      @base_query = MonthSalesPerformanceReport.where(date_pk: @start_date..@end_date)
    elsif @period == '5_year'
      @start_date = Date.tomorrow - 5.years
      @base_query = YearSalesPerformanceReport.where(sales_year: (@start_date.year)..(@end_date.year))
      @id_field_name = :sales_year
    else
      @start_date = Ipos::Sale.all.minimum(:tanggal)
      @base_query = MonthSalesPerformanceReport.all
    end
  end

  def extract_params
    permitted_params = params.permit(:period,:value_type,:separate_purchase_year,suppliers:[],brands:[],item_types:[])
    @period = permitted_params.fetch(:period, 'month')
    @supplier_codes = permitted_params.fetch(:suppliers, [])
    @brand_names = permitted_params.fetch(:brands, [])
    @item_type_names = permitted_params.fetch(:item_types, [])
    @value_type = permitted_params.fetch(:value_type,'sales_total')
    @separate_purchase_year = params.fetch(:separate_purchase_year, '0') == '1'
    if !['sales_total','sales_quantity','sales_discount_quantity'].include?(@value_type)
      raise 'parameter value type invalid'
    end
    if @supplier_codes.empty?
      raise 'supplier must not Empty'
    end
  end
end
