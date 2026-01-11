class ItemSalesPerformanceReport::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @item_sales_performance_reports = find_item_sales_performance_reports
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(ItemSalesPerformanceReportSerializer.new(@item_sales_performance_reports, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @item_sales_performance_reports.total_count,
      total_pages: @item_sales_performance_reports.total_pages
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(ItemSalesPerformanceReport)
    allowed_includes = [:item_sales_performance_report]
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
    @fields = filter_authorize_fields(fields: result.fields, record_class: ItemSalesPerformanceReport)
  end

  def find_item_sales_performance_reports
    item_sales_performance_reports = ItemSalesPerformanceReport.all.includes(@query_included)
                                                               .page(@page)
                                                               .per(@limit)
    if @search_text.present?
      item_sales_performance_reports = item_sales_performance_reports.where(['name ilike ? '] + Array.new(1,
                                                                                                          "%#{@search_text}%"))
    end
    @filters.each do |filter|
      item_sales_performance_reports = filter.add_filter_to_query(item_sales_performance_reports)
    end
    if @sort.present?
      item_sales_performance_reports.order(@sort)
    else
      item_sales_performance_reports.order(id: :asc)
    end
  end
end
