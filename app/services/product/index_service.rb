class Product::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @products = find_products
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(ProductSerializer.new(@products,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @products.total_count,
       total_pages: @products.total_pages,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Product)
    allowed_fields = [:product]
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

  def find_products
    products = Product.all.includes(@query_included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      products = products.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      products = filter.add_filter_to_query(products)
    end
    if @sort.present?
      products = products.order(@sort)
    else
      products = products.order(id: :asc)
    end
    products
  end

end
