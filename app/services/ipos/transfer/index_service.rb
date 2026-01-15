class Ipos::Transfer::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @transfers = find_transfers
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::TransferSerializer.new(@transfers, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @transfers.total_count,
      total_pages: @transfers.total_pages
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::Transfer)
    allowed_includes = [:transfer]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Transfer)
  end

  def find_transfers
    transfers = Ipos::Transfer.all.includes(@included)
                              .page(@page)
                              .per(@limit)
    transfers = transfers.where(['notransaksi ilike ? '] + Array.new(1, "%#{@search_text}%")) if @search_text.present?
    @filters.each do |filter|
      transfers = transfers.where(filter.to_query)
    end
    if @sort.present?
      transfers.order(@sort)
    else
      transfers.order(tanggal: :desc)
    end
  end
end
