class PayrollType::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @payroll_types = find_payroll_types
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(PayrollTypeSerializer.new(@payroll_types, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @payroll_types.total_count,
      total_pages: @payroll_types.total_pages
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(PayrollType)
    allowed_includes = [:payroll_type]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: PayrollType)
  end

  def find_payroll_types
    payroll_types = PayrollType.all.includes(@included)
                               .page(@page)
                               .per(@limit)
    payroll_types = payroll_types.where(['name ilike ? '] + Array.new(1, "%#{@search_text}%")) if @search_text.present?
    @filters.each do |filter|
      payroll_types = payroll_types.where(filter.to_query)
    end
    if @sort.present?
      payroll_types.order(@sort)
    else
      payroll_types.order(id: :asc)
    end
  end
end
