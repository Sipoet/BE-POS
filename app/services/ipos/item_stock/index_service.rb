# frozen_string_literal: true
class Ipos::ItemStock::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @item_stocks = find_item_stocks
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::ItemStockSerializer.new(@item_stocks,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @item_stocks.total_count,
       total_pages: @item_stocks.total_pages,
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::ItemStock)
    allowed_includes = [:item_stock]
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
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::ItemStock)
  end

  def find_item_stocks
    item_stocks = Ipos::ItemStock.all.includes(@query_included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      item_stocks = item_stocks.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      item_stocks = filter.add_filter_to_query(item_stocks)
    end
    if @sort.present?
      item_stocks = item_stocks.order(@sort)
    else
      item_stocks = item_stocks.order(id: :asc)
    end
    item_stocks
  end

end
