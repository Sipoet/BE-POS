class EmployeeLeave::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @employee_leaves = find_employee_leaves
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(EmployeeLeaveSerializer.new(@employee_leaves,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @employee_leaves.total_pages,
    }
  end

  def extract_params
    allowed_columns = EmployeeLeave::TABLE_HEADER.map(&:name)
    allowed_fields = [:employee_leave]
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

  def find_employee_leaves
    employee_leaves = EmployeeLeave.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      employee_leaves = employee_leaves.where(['name ilike ? ']+ Array.new(1,"%%"))
    end
    @filters.each do |filter|
      employee_leaves = employee_leaves.where(filter.to_query)
    end
    if @sort.present?
      employee_leaves = employee_leaves.order(@sort)
    else
      employee_leaves = employee_leaves.order(name: :asc)
    end
    employee_leaves
  end

end
