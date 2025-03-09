class Brand::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @brands = find_brands
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::BrandSerializer.new(@brands,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @brands.total_pages,
      total_rows: @brands.total_count,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Brand)
    allowed_fields = [:brand]
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

  def find_brands
    brands = Ipos::Brand.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      brands = brands.where(['merek ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      brands = brands.where(filter.to_query)
    end
    if @sort.present?
      brands = brands.order(@sort)
    else
      brands = brands.order(merek: :asc)
    end
    brands
  end

end
