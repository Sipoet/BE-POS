class Payslip::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @payslips = find_payslips
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(PayslipSerializer.new(@payslips,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @payslips.total_pages,
    }
  end

  def extract_params
    allowed_columns = Payslip::TABLE_HEADER.map(&:name) - ['employee_name']
    allowed_fields = ['payslip','payroll','employee']
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = result.fields
  end

  def find_payslips
    payslips = Payslip.all.includes(@included)
      .page(@page)
      .per(@limit)
    @filters.each do |filter|
      payslips = payslips.where(filter.to_query)
    end
    if @sort.present?
      payslips = payslips.order(@sort)
    else
      payslips = payslips.order(id: :asc)
    end
    payslips
  end

end
