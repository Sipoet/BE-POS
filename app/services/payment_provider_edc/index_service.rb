class PaymentProviderEdc::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @payment_provider_edcs = find_payment_provider_edcs
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(PaymentProviderEdcSerializer.new(@payment_provider_edcs, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @payment_provider_edcs.total_count,
      total_pages: @payment_provider_edcs.total_pages
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(PaymentProviderEdc)
    allowed_includes = [:payment_provider_edc]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: PaymentProviderEdc)
  end

  def find_payment_provider_edcs
    payment_provider_edcs = PaymentProviderEdc.all.includes(@included)
                                              .page(@page)
                                              .per(@limit)
    if @search_text.present?
      payment_provider_edcs = payment_provider_edcs.where(['terminal_id ilike ? OR merchant_id ilike ?'] + Array.new(2,
                                                                                                                     "%#{@search_text}%"))
    end
    @filters.each do |filter|
      payment_provider_edcs = payment_provider_edcs.where(filter.to_query)
    end
    if @sort.present?
      payment_provider_edcs.order(@sort)
    else
      payment_provider_edcs.order(id: :asc)
    end
  end
end
