class Transfer::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @transfers = find_transfers
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::TransferSerializer.new(@transfers,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @transfers.count,
       total_pages: @transfers.total_pages,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Transfer)
    allowed_fields = [:transfer]
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

  def find_transfers
    transfers = Ipos::Transfer.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      transfers = transfers.where(['notransaksi ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      transfers = transfers.where(filter.to_query)
    end
    if @sort.present?
      transfers = transfers.order(@sort)
    else
      transfers = transfers.order(tanggal: :desc)
    end
    transfers
  end

end
