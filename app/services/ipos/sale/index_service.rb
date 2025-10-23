class Ipos::Sale::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @sales = find_sales
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::SaleSerializer.new(@sales, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @sales.total_pages,
      total_rows: @sales.total_count
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::Sale)
    allowed_includes = %i[sale sale_items]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Sale)
  end

  def find_sales
    sales = Ipos::Sale.all.includes(@included)
                      .page(@page)
                      .per(@limit)
    sales = sales.where(['notransaksi ilike ? '] + Array.new(1, "%#{@search_text}%")) if @search_text.present?
    @filters.each do |filter|
      sales = sales.where(filter.to_query)
    end
    if @sort.present?
      sales.order(@sort)
    else
      sales.order(tanggal: :desc)
    end
  end
end
