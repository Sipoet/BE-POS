class ItemTypeSalesPerformanceReport::GroupBySupplierService < ApplicationService

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
        supplier_codes: @supplier_codes,
        last_purchase_years: @last_purchase_years,
        item_type_name: @item_type_name
      },
    })
  end

  private

  def find_reports
    query = @base_query.order(supplier_code: :asc,@id_field_name => :asc)
                       .where(item_type_name: @item_type_name)

    if @supplier_codes.any?
      query = query.where(supplier_code: @supplier_codes)
    end
    if @brand_names.any?
      query = query.where(brand_name: @brand_names)
    end
    if @last_purchase_years.any?
      query = query.where(last_purchase_year: @last_purchase_years)
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
    case @group_period
    when 'hourly'
      hour_int = Setting.get('day_separator_at')&.split(':')&.first&.to_i || 7
      (hour_int..23).to_a + (0..(hour_int - 1)).to_a
    when 'daily'
      date = reports.min_by(&:date_pk)&.date_pk || @start_date
      ((date.to_date)..(@end_date.to_date)).to_a
    when 'dow'
      [1,2,3,4,5,6,0]
    when 'weekly'
      date = @start_date
      end_date_cweek = @end_date.to_date.cweek
      end_date_year = @end_date.year

      list = []
      loop do
        break if date.year > end_date_year
        break if (date.year == end_date_year && date.to_date.cweek > end_date_cweek)
        list << date.strftime('%Y-%V')
        date = date.next_week
      end
      list
    when 'monthly'
      date = reports.min_by(&:date_pk)&.date_pk || @start_date
      list = []
      loop do
        break if date.year > @end_date.year
        break if (date.year == @end_date.year && date.month > @end_date.month)
        list << date
        date = date.next_month
      end
      list
    when 'yearly'
      start_year = (reports.min_by(&:date_pk)&.date_pk || @start_date).to_i
      (start_year..(@end_date.year)).to_a
    else
      reports.map(&:date_pk).uniq.sort
    end
  end

  def group_by_supplier(reports,identifier_list)
    suppliers = Ipos::Supplier.where(code: reports.map(&:supplier_code).uniq).index_by(&:code)
    reports.group_by{|row|[row.supplier_code, row.last_purchase_year].compact}
           .map do |keys,values|
              row = LineResult.new(supplier_code: keys[0], last_purchase_year: keys[1])
              if !values.empty?
                value_hash = values.index_by(&:date_pk)
                identifier_list.each do |date_pk|
                  row.add_spot([date_pk, value_hash[date_pk]&.value || 0.0])
                end
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

    def initialize(supplier_code:,supplier_name: nil,last_purchase_year: nil, spots:[])
      @supplier_code = supplier_code
      @last_purchase_year = last_purchase_year
      @supplier_name = supplier_name
      @spots = spots
    end

    def add_spot(spot)
      @spots << spot
    end

  end

  def extract_date_range
    @end_date = Date.yesterday.end_of_day
    @id_field_name = :date_pk
    case @range_period
    when 'day'
      @start_date = Date.today.beginning_of_day
      @end_date = Date.today.end_of_day
    when 'week'
      @start_date = Date.today - 6.days
    when 'month'
      @start_date = Date.today - 1.month
    when 'year'
      @start_date = Date.tomorrow - 1.year
    when '5_year'
      @start_date = Date.tomorrow - 5.years
    else
      @start_date = Ipos::Sale.all.minimum(:tanggal)
    end

    case @group_period
    when 'hourly'
      @id_field_name = :sales_hour
      @base_query = ItemSalesPerformanceReport.where(date_pk: @start_date..@end_date)
    when 'daily'
      @base_query = DaySalesPerformanceReport.where(date_pk: @start_date..@end_date)
    when 'dow'
      @id_field_name = :sales_day_of_week
      @base_query = ItemSalesPerformanceReport.where(date_pk: @start_date..@end_date)
    when 'weekly'
      @base_query = WeekSalesPerformanceReport.where(date_pk: (@start_date.strftime('%Y-%V'))..(@end_date.strftime('%Y-%V')))
    when 'monthly'
      @base_query = MonthSalesPerformanceReport.where(date_pk: (@start_date.beginning_of_month)..(@end_date.end_of_month))
    when 'yearly'
      @id_field_name = :sales_year
      @base_query = YearSalesPerformanceReport.where(sales_year: (@start_date.year)..(@end_date.year))
    else
      raise 'invalid group period'
    end
  end

  def extract_params
    permitted_params = params.permit(:range_period,:group_period,:value_type,:separate_purchase_year,:item_type_name,last_purchase_years:[],brands:[],suppliers:[])
    @range_period = permitted_params.fetch(:range_period, 'month')
    @group_period = permitted_params.fetch(:group_period, 'daily')
    @item_type_name = permitted_params[:item_type_name]
    @supplier_codes = permitted_params.fetch(:suppliers, [])
    @brand_names = permitted_params.fetch(:brands, [])
    @value_type = permitted_params.fetch(:value_type,'sales_total')
    @last_purchase_years = permitted_params.fetch(:last_purchase_years,[])
    @separate_purchase_year = params.fetch(:separate_purchase_year, '0') == '1'
    if !['sales_total','sales_quantity','sales_discount_amount'].include?(@value_type)
      raise 'parameter value type invalid'
    end
    if !['hourly','daily','dow','weekly','monthly','yearly'].include?(@group_period)
      raise 'parameter group period invalid'
    end
    if !['day', 'week', 'month', 'year', '5_year', 'all'].include?(@range_period)
      raise 'parameter range period invalid'
    end
    if @item_type_name.nil?
      raise 'Item Type must not null'
    end
  end

end
