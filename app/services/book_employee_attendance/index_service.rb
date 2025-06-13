class BookEmployeeAttendance::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @book_employee_attendances = find_book_employee_attendances
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(BookEmployeeAttendanceSerializer.new(@book_employee_attendances,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @book_employee_attendances.total_count,
       total_pages: @book_employee_attendances.total_pages,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(BookEmployeeAttendance)
    allowed_fields = [:book_employee_attendance]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @query_included = result.query_included
    @filters = result.filters
    @fields = result.fields
  end

  def find_book_employee_attendances
    book_employee_attendances = BookEmployeeAttendance.all.includes(@query_included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      book_employee_attendances = book_employee_attendances.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      book_employee_attendances = filter.add_filter_to_query(book_employee_attendances)
    end
    if @sort.present?
      book_employee_attendances = book_employee_attendances.order(@sort)
    else
      book_employee_attendances = book_employee_attendances.order(id: :asc)
    end
    book_employee_attendances
  end

end
