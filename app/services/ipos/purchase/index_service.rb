class Ipos::Purchase::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @purchases = find_purchases
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::PurchaseSerializer.new(@purchases, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @purchases.total_pages,
      total_rows: @purchases.total_count
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::Purchase)
    allowed_includes = %i[purchase purchase_items supplier purchase_order]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Purchase)
  end

  def find_purchases
    purchases = Ipos::Purchase.all.includes(@included)
                              .page(@page)
                              .per(@limit)
    purchases = purchases.where(['notransaksi ilike ? '] + Array.new(1, "%#{@search_text}%")) if @search_text.present?
    @filters.each do |filter|
      purchases = purchases.where(filter.to_query)
    end
    if @sort.present?
      purchases.order(@sort)
    else
      purchases.order(tanggal: :desc)
    end
  end
end
