class Purchase::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @purchases = find_purchases
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::PurchaseSerializer.new(@purchases,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @purchases.total_pages,
      total_rows: @purchases.total_count,
    }
  end

  def extract_params
    allowed_columns = Ipos::Purchase::TABLE_HEADER.map(&:name)
    allowed_fields = [:purchase, :purchase_items]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = result.fields
  end

  def find_purchases
    purchases = Ipos::Purchase.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      purchases = purchases.where(['notransaksi ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      purchases = purchases.where(filter.to_query)
    end
    if @sort.present?
      purchases = purchases.order(@sort)
    else
      purchases = purchases.order(tanggal: :desc)
    end
    purchases
  end

end
