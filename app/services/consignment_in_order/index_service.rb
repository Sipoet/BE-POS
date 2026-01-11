class ConsignmentInOrder::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @consignment_in_orders = find_consignment_in_orders
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::ConsignmentInOrderSerializer.new(@consignment_in_orders, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @consignment_in_orders.total_count,
      total_pages: @consignment_in_orders.total_pages
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::ConsignmentInOrder)
    allowed_includes = [:consignment_in_order]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @query_included = result.query_included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::ConsignmentInOrder)
  end

  def find_consignment_in_orders
    consignment_in_orders = Ipos::ConsignmentInOrder.all.includes(@query_included)
                                                    .page(@page)
                                                    .per(@limit)
    if @search_text.present?
      consignment_in_orders = consignment_in_orders.where(['name ilike ? '] + Array.new(1, "%#{@search_text}%"))
    end
    @filters.each do |filter|
      consignment_in_orders = filter.add_filter_to_query(consignment_in_orders)
    end
    if @sort.present?
      consignment_in_orders.order(@sort)
    else
      consignment_in_orders.order(id: :asc)
    end
  end
end
