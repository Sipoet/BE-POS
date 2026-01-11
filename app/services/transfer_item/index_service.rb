class TransferItem::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @transfer_items = find_transfer_items
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::TransferItemSerializer.new(@transfer_items, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @transfer_items.total_count,
      total_pages: @transfer_items.total_pages
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::TransferItem)
    allowed_includes = %i[transfer_item item]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::TransferItem)
  end

  def find_transfer_items
    transfer_items = Ipos::TransferItem.all.includes(@included)
                                       .page(@page)
                                       .per(@limit)
    if @search_text.present?
      transfer_items = transfer_items.where(['name ilike ? '] + Array.new(1, "%#{@search_text}%"))
    end
    @filters.each do |filter|
      transfer_items = transfer_items.where(filter.to_query)
    end
    if @sort.present?
      transfer_items.order(@sort)
    else
      transfer_items.order(id: :asc)
    end
  end
end
