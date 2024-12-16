class PayrollType::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @payroll_types = find_payroll_types
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(PayrollTypeSerializer.new(@payroll_types,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @payroll_types.count,
       total_pages: @payroll_types.total_pages,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(PayrollType)
    allowed_fields = [:payroll_type]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = result.fields
  end

  def find_payroll_types
    payroll_types = PayrollType.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      payroll_types = payroll_types.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      payroll_types = payroll_types.where(filter.to_query)
    end
    if @sort.present?
      payroll_types = payroll_types.order(@sort)
    else
      payroll_types = payroll_types.order(id: :asc)
    end
    payroll_types
  end

end
