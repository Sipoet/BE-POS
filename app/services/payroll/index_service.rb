class Payroll::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @payrolls = find_payrolls
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(PayrollSerializer.new(@payrolls,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @payrolls.total_pages,
    }
  end

  def extract_params
    allowed_columns = Payroll::TABLE_HEADER.map(&:name)
    allowed_fields = [:payroll, :payroll_line, :work_schedule]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @field = result.field
  end

  def find_payrolls
    payrolls = Payroll.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      payrolls = payrolls.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      payrolls = payrolls.where(filter.to_query)
    end
    if @sort.present?
      payrolls = payrolls.order(@sort)
    else
      payrolls = payrolls.order(name: :asc)
    end
    payrolls
  end

end
