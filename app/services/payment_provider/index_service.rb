class PaymentProvider::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @payment_providers = find_payment_providers
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(PaymentProviderSerializer.new(@payment_providers, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @payment_providers.total_count,
      total_pages: @payment_providers.total_pages
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(PaymentProvider)
    allowed_includes = %i[payment_provider payment_provider_edcs]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: PaymentProvider)
  end

  def find_payment_providers
    payment_providers = PaymentProvider.all.includes(@included)
                                       .page(@page)
                                       .per(@limit)
    if @search_text.present?
      payment_providers = payment_providers.where(['name ilike ? '] + Array.new(1, "%#{@search_text}%"))
    end
    @filters.each do |filter|
      payment_providers = payment_providers.where(filter.to_query)
    end
    if @sort.present?
      payment_providers.order(@sort)
    else
      payment_providers.order(id: :asc)
    end
  end
end
