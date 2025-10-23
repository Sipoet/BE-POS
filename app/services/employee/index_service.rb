class Employee::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @employees = find_employees
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(EmployeeSerializer.new(@employees, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @employees.total_pages,
      total_rows: @employees.total_count
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Employee)
    allowed_includes = %i[employee payroll role]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Employee)
  end

  def find_employees
    employees = Employee.all.includes(@included)
                        .page(@page)
                        .per(@limit)
    if @search_text.present?
      employees = employees.where(['code ILIKE ? OR name ILIKE ? '] + Array.new(2, "%#{@search_text}%"))
    end
    @filters.each do |filter|
      employees = employees.where(filter.to_query)
    end
    if @sort.present?
      employees.order(@sort)
    else
      employees.order(id: :asc)
    end
  end
end
