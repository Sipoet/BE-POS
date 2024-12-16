class EmployeeAttendance::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @employee_attendances = find_employee_attendances
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(EmployeeAttendanceSerializer.new(@employee_attendances,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @employee_attendances.total_pages,
      total_rows: @employee_attendances.total_count,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(EmployeeAttendance)
    allowed_fields = [:employee_attendance, :employee]
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

  def find_employee_attendances
    employee_attendances = EmployeeAttendance.all
                                             .includes(@included)
                                              .page(@page)
                                              .per(@limit)

    @filters.each do |filter|
      employee_attendances = employee_attendances.where(filter.to_query)
    end
    if @sort.present?
      employee_attendances = employee_attendances.order(@sort)
    else
      employee_attendances = employee_attendances.order(id: :asc)
    end
    employee_attendances
  end

end
