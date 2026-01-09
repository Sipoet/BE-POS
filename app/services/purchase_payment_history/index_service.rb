class PurchasePaymentHistory::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @purchase_payment_histories = find_purchase_payment_histories
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(PurchasePaymentHistorySerializer.new(@purchase_payment_histories, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @purchase_payment_histories.total_count,
      total_pages: @purchase_payment_histories.total_pages
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(PurchasePaymentHistory)
    allowed_includes = %i[purchase_payment_history supplier purchase purchase_order payment_account]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @query_included = result.query_included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: PurchasePaymentHistory)
  end

  def find_purchase_payment_histories
    purchase_payment_histories = PurchasePaymentHistory.all.includes(@query_included)
                                                       .page(@page)
                                                       .per(@limit)
    if @search_text.present?
      query_search_arr = ['purchase_code ilike ?', 'code ilike ?',
                          'purchase_order_code ilike ?',
                          'description ilike ?',
                          'supplier_code ilike ?', 'tbl_supel.nama ilike ?']
      purchase_payment_histories = purchase_payment_histories.left_outer_joins(:supplier).where([query_search_arr.join(' OR ')] + Array.new(6,
                                                                                                                                            "%#{@search_text}%"))
    end
    @filters.each do |filter|
      purchase_payment_histories = filter.add_filter_to_query(purchase_payment_histories)
    end
    if @sort.present?
      purchase_payment_histories.order(@sort)
    else
      purchase_payment_histories.order(id: :asc)
    end
  end
end
