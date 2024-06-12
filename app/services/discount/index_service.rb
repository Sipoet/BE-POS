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
      total_rows: @discounts.total_count,
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
    filter_discount_ids = []
    @filters.each do |filter|
      if filter.key.to_sym == :item_code
        filter_discount_ids << DiscountItem.where(filter.to_query).distinct(:discount_id).pluck(:discount_id)
      elsif filter.key.to_sym == :item_type_name
        filter_discount_ids << DiscountItemType.where(filter.to_query).distinct(:discount_id).pluck(:discount_id)
      elsif filter.key.to_sym == :supplier_code
        filter_discount_ids << DiscountSupplier.where(filter.to_query).distinct(:discount_id).pluck(:discount_id)
      elsif filter.key.to_sym == :brand_name
        filter_discount_ids << DiscountBrand.where(filter.to_query).distinct(:discount_id).pluck(:discount_id)
      else
        discounts = discounts.where(filter.to_query)
      end
    end
    if filter_discount_ids.present?
      container_discount_ids = filter_discount_ids.first
      filter_discount_ids[1..-1].each do |discount_ids|
        container_discount_ids &= discount_ids
      end
      discounts = discounts.where(id: container_discount_ids)
    end
    if @sort.present?
      discounts = discounts.order(@sort)
    else
      discounts = discounts.order(id: :asc)
    end
    discounts
  end

end
