class Item::WithDiscountService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @items = find_items
    options = {
      meta: meta,
      # fields: @fields,
      params:{include: @included},
      include: @included
    }
    results = @items.map do |item|
      Result.new(
        item_code: item.item_code,
        item_name: item.item_name,
        warehouse_stock: item.warehouse_stock,
        uom: item.uom,
        sell_price: item.sell_price,
        store_stock: item.store_stock,
        discount: active_discount(item.item_code))
    end
    render_json(ItemWithDiscountSerializer.new(results,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages:1,
      total_rows: @items.length,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Item)
    allowed_fields = [:item,:discount]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = [:code,:name,:sell_price,:sell_price_after_discount,:uom,:discount_desc]
  end

  def find_items
    items = ItemReport.all.includes(@included)
    if @search_text.present?
      items = items.where(['item_name ilike ?',"%#{@search_text}%"])
                   .or(ItemReport.where(item_code: @search_text))
    end
    @filters.each do |filter|
      items = items.where(filter.to_query)
    end
    if @sort.present?
      items = items.order(@sort)
    else
      items = items.order(item_code: :asc)
    end
    items
  end

  def active_discount(item_code)
    Ipos::ItemPromotion.find_by(kodeitem: item_code,promotion: Ipos::Promotion.active_today)&.discount
  end

  class Result
    attr_accessor :item_code, :item_name,
                  :sell_price, :uom, :discount,
                  :store_stock,:warehouse_stock
    def initialize(options)
      @item_code = options[:item_code]
      @item_name = options[:item_name]
      @sell_price = options[:sell_price]
      @uom = options[:uom]
      @store_stock = options[:store_stock]
      @warehouse_stock = options[:warehouse_stock]
      @discount = options[:discount]
    end

    def stock_left
      @warehouse_stock + @store_stock
    end

    def id
      @item&.code
    end
  end
end
