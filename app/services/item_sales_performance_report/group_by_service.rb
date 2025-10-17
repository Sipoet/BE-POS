class ItemSalesPerformanceReport::GroupByService < ApplicationService

  def execute_service
    extract_params
    extract_date_range
    reports = find_reports
    identifier_list = get_identifiers(reports)
    grouped_report = group_by(reports,identifier_list)
    render_json({
      data: grouped_report,
      metadata: {
        start_date: @validator.start_date,
        end_date: @validator.end_date,
        identifier_list: identifier_list,
        brand_names: @validator.brand_names,
        item_type_names: @validator.item_type_names,
        supplier_codes: @validator.supplier_codes,
        item_codes: @validator.item_codes,
        last_purchase_years: @validator.last_purchase_years,
        group_type: @validator.group_type,
        group_period: @validator.group_period,
        value_type: @validator.value_type,
        separate_purchase_year: @validator.separate_purchase_year
      },
    })
  rescue ValidationError => e
    render_json({message: 'Gagal Ambil Data',errors: @validator.errors.full_messages},{status: :conflict})
  end

  private

  def start_stock_query
    query = ItemMovement.where(ApplicationRecord.sanitize_sql(['transaction_date < ?',@validator.start_date]))
    query = filter_query(query)
    query = query.group(@validator.indicator_field)
                 .sum(:quantity)
  end

  def period_increase_stock_query
    query = ItemMovement.where(transaction_date: @validator.start_date..(@validator.end_date), movement_type: :in)
    query = filter_query(query)
    query = query.group(@validator.indicator_field)
                 .sum(:quantity)
  end

  def filter_query(query)
    if @validator.supplier_codes.any?
      query = query.where(supplier_code: @validator.supplier_codes)
    end
    if @validator.brand_names.any?
      query = query.where(brand_name: @validator.brand_names)
    end
    if @validator.item_type_names.any?
      query = query.where(item_type_name: @validator.item_type_names)
    end
    if @validator.last_purchase_years.any?
      query = query.where(last_purchase_year: @validator.last_purchase_years)
    end
    query
  end

  def find_reports
    query = @base_query.order(query_sort)
    query = filter_query(query)
    group_field = get_group_field
    sum_field = @validator.value_type == 'sales_through_rate' ? 'sales_quantity': @validator.value_type
    query = query.group(group_field)
                 .sum(sum_field)
    name_of = ->(keys,value){keys[0]}
    date_pk_of = ->(keys,value){keys[1]}
    last_purchase_year_of = ->(keys,value){keys[2]}

    if @validator.group_type == 'period'
      name_of = ->(keys,value){'All'}
      if @validator.separate_purchase_year
        last_purchase_year_of = ->(keys,value){keys[1]}
        date_pk_of = ->(keys,value){keys[0]}
      else
        last_purchase_year_of = ->(keys,value){nil}
        date_pk_of = ->(key,value){key}
      end
    end

    query.map do |keys,value|
      QueryResult.new(
        name: name_of.call(keys,value),
        date_pk: date_pk_of.call(keys,value),
        last_purchase_year: last_purchase_year_of.call(keys,value),
        value: value
      )
    end
  end

  def query_sort
    if @validator.group_type == 'period'
      {@validator.period_indicator_field => :asc}
    else
      {@validator.indicator_field => :asc, @validator.period_indicator_field => :asc}
    end
  end

  def get_group_field
    group_field = [@validator.period_indicator_field]
    if @validator.separate_purchase_year
      group_field << :last_purchase_year
    end
    if @validator.group_type != 'period'
      group_field.unshift(@validator.indicator_field)
    end
    group_field
  end

  def get_identifiers(reports)
    start_date = @validator.start_date
    end_date = @validator.end_date
    case @validator.group_period
    when 'hourly'
      hour_int = Setting.get('day_separator_at')&.split(':')&.first&.to_i || 7
      return (hour_int..23).to_a + (0..(hour_int - 1)).to_a
    when 'daily'
      date = reports.min_by(&:date_pk)&.date_pk || start_date
      return ((date.to_date)..(end_date.to_date)).to_a
    when 'dow'
      return [1,2,3,4,5,6,0]
    when 'weekly'
      date = start_date
      end_date_cweek = end_date.to_date.cweek
      end_date_year = end_date.year
      list = []
      loop do
        break if date.year > end_date_year
        break if (date.year == end_date_year && date.to_date.cweek > end_date_cweek)
        list << date.strftime('%Y-%V')
        date = date.next_week
      end
      return list
    when 'monthly'
      Rails.logger.debug "Masuk identifier"
      date = reports.min_by(&:date_pk)&.date_pk || start_date
      list = []
      loop do
        break if date.year > end_date.year
        break if (date.year == end_date.year && date.month > end_date.month)
        list << date
        date = date.next_month
      end
      return list
    when 'yearly'
      start_year = (reports.min_by(&:date_pk)&.date_pk || start_date).to_i
      return (start_year..(end_date.year)).to_a
    else
      return reports.map(&:date_pk).uniq.sort
    end
  end

  def group_by(reports,identifier_list)
    lines = models_of(@validator.group_type, reports.map(&:name).uniq)
    description_key = ['brand','item_type'].include?(@validator.group_type) ? :description : :name
    grouped = reports.group_by{|row|[row.name, row.last_purchase_year].compact}
    if @validator.value_type == 'sales_through_rate'
      start_stock = start_stock_query
      period_increase_stock = period_increase_stock_query
      grouped.map do |keys,values|
        row = LineResult.new(name: keys[0], last_purchase_year: keys[1])
        row.start_stock = (start_stock[row.name] || 0)
        row.increase_period_stock = (period_increase_stock[row.name] || 0)
        total_stock = row.start_stock.to_d + row.increase_period_stock.to_d
        row.sales_quantity = 0
        if !values.empty?
          value_hash = values.index_by(&:date_pk)
          identifier_list.each do |date_pk|
            sales_quantity = value_hash[date_pk]&.value || 0.0
            rate = total_stock == 0 ? 1 : (sales_quantity.to_d / total_stock)
            row.add_spot([date_pk, rate.to_f])
            total_stock -= sales_quantity
            row.sales_quantity += sales_quantity
          end
        end
        row.description = lines[row.name].try(description_key)
        row
      end
    else
      grouped.map do |keys,values|
        row = LineResult.new(name: keys[0], last_purchase_year: keys[1])
        if !values.empty?
          value_hash = values.index_by(&:date_pk)
          identifier_list.each do |date_pk|
            row.add_spot([date_pk, value_hash[date_pk]&.value || 0.0])
          end
        end
        row.description = lines[row.name].try(description_key)
        row
      end
    end
  end


  def models_of(group_type, values)
    case group_type
    when 'supplier'
      Ipos::Supplier.where(code: values).index_by(&:code)
    when 'brand'
      Ipos::Brand.where(name: values).index_by(&:name)
    when 'item_type'
      Ipos::ItemType.where(name: values).index_by(&:name)
    when 'item'
      Ipos::Item.where(code: values).index_by(&:code)
    else
      {}
    end
  end

  class QueryResult
    attr_accessor :name, :last_purchase_year, :date_pk, :value

    def initialize(name:,last_purchase_year: nil,value:,date_pk:)
      @name = name
      @last_purchase_year = last_purchase_year
      @date_pk = date_pk
      @value = value.to_f
    end

  end

  class LineResult
    attr_accessor :name, :description, :last_purchase_year, :spots,
                  :sales_quantity, :start_stock, :increase_period_stock

    def initialize(name:,description: nil,last_purchase_year: nil, spots:[])
      @name = name
      @last_purchase_year = last_purchase_year
      @spots = spots
      @description = description
    end

    def add_spot(spot)
      @spots << spot
    end

  end

  def extract_date_range
    start_date = @validator.start_date
    end_date = @validator.end_date
    case @validator.group_period
    when 'hourly'
      @base_query = ItemSalesPerformanceReport.where(date_pk: start_date..end_date)
    when 'daily'
      @base_query = DaySalesPerformanceReport.where(date_pk: start_date..end_date)
    when 'dow'
      @base_query = ItemSalesPerformanceReport.where(date_pk: start_date..end_date)
    when 'weekly'
      @base_query = WeekSalesPerformanceReport.where(date_pk: (start_date.strftime('%Y-%V'))..(end_date.strftime('%Y-%V')))
    when 'monthly'
      @base_query = MonthSalesPerformanceReport.where(date_pk: (start_date.beginning_of_month)..(end_date.end_of_month))
    when 'yearly'
      @base_query = YearSalesPerformanceReport.where(sales_year: (start_date.year)..(end_date.year))
    else
      raise 'invalid group period'
    end
  end

  def extract_params
    permitted_params = params.permit(:group_type,:group_period,:value_type,:start_date,:end_date,:separate_purchase_year,last_purchase_years:[],supplier_codes:[],brand_names:[],item_type_names:[],item_codes:[])
    @validator = ItemSalesPerformanceReport::GroupByValidator.new(permitted_params)
    raise ValidationError if !@validator.valid?

    if @validator.start_date.year <= 1000
      @validator.start_date = Ipos::Sale.all.minimum(:tanggal)
    end
  end

end
