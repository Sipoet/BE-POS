class EmployeeLeave::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @employee_leaves = find_employee_leaves
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(EmployeeLeaveSerializer.new(@employee_leaves, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @employee_leaves.total_pages,
      total_rows: @employee_leaves.total_count
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(EmployeeLeave)
    allowed_includes = %i[employee_leave employee]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: EmployeeLeave)
  end

  def find_employee_leaves
    employee_leaves = EmployeeLeave.all.includes(@included)
                                   .page(@page)
                                   .per(@limit)

    @filters.each do |filter|
      employee_leaves = employee_leaves.where(filter.to_query)
    end
    if @sort.present?
      employee_leaves.order(@sort)
    else
      employee_leaves.order(id: :asc)
    end
  end
end
