class Brand::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @brands = find_brands
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::BrandSerializer.new(@brands, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @brands.total_pages,
      total_rows: @brands.total_count
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Brand)
    allowed_includes = [:brand]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Brand)
  end

  def find_brands
    brands = Ipos::Brand.all.includes(@included)
                        .page(@page)
                        .per(@limit)
    brands = brands.where(['merek ilike ? '] + Array.new(1, "%#{@search_text}%")) if @search_text.present?
    @filters.each do |filter|
      brands = brands.where(filter.to_query)
    end
    if @sort.present?
      brands.order(@sort)
    else
      brands.order(merek: :asc)
    end
  end
end
