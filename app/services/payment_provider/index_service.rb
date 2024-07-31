class PaymentProvider::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @payment_providers = find_payment_providers
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(PaymentProviderSerializer.new(@payment_providers,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @payment_providers.count,
       total_pages: @payment_providers.total_pages,
    }
  end

  def extract_params
    allowed_columns = PaymentProvider::TABLE_HEADER.map(&:name)
    allowed_fields = [:payment_provider]
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

  def find_payment_providers
    payment_providers = PaymentProvider.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      payment_providers = payment_providers.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      payment_providers = payment_providers.where(filter.to_query)
    end
    if @sort.present?
      payment_providers = payment_providers.order(@sort)
    else
      payment_providers = payment_providers.order(id: :asc)
    end
    payment_providers
  end

end
