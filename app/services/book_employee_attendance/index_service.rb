class BookEmployeeAttendance::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @book_employee_attendances = find_book_employee_attendances
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(BookEmployeeAttendanceSerializer.new(@book_employee_attendances, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @book_employee_attendances.total_count,
      total_pages: @book_employee_attendances.total_pages
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(BookEmployeeAttendance)
    allowed_includes = %i[book_employee_attendance employee]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @query_included = result.query_included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: BookEmployeeAttendance)
  end

  def find_book_employee_attendances
    book_employee_attendances = BookEmployeeAttendance.all.includes(@query_included)
                                                      .page(@page)
                                                      .per(@limit)
    if @search_text.present?
      book_employee_attendances = book_employee_attendances.where(['name ilike ? '] + Array.new(1, "%#{@search_text}%"))
    end
    @filters.each do |filter|
      book_employee_attendances = filter.add_filter_to_query(book_employee_attendances)
    end
    if @sort.present?
      book_employee_attendances.order(@sort)
    else
      book_employee_attendances.order(id: :asc)
    end
  end
end
