class Discount::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @discounts = find_discounts
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(DiscountSerializer.new(@discounts,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @discounts.total_pages,
    }
  end

  def extract_params
    allowed_columns = Discount::TABLE_HEADER.map(&:name)
    allowed_fields = [:discount, :item, :item_type, :supplier, :brand,
                      :blacklist_brand, :blacklist_item_type,
                      :blacklist_supplier]
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

  def find_discounts
    discounts = Discount.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      discounts = discounts.where(['code ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      discounts = discounts.where(filter.to_query)
    end
    if @sort.present?
      discounts = discounts.order(@sort)
    else
      discounts = discounts.order(id: :asc)
    end
    discounts
  end

end
