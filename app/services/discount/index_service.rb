class Discount::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @discounts = find_discounts
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(DiscountSerializer.new(@discounts, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @discounts.total_pages,
      total_rows: @discounts.total_count
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Discount)
    allowed_includes = %i[discount customer_group discount_filters]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Discount)
  end

  def find_discounts
    discounts = Discount.all.includes(@included)
                        .page(@page)
                        .per(@limit)
    discounts = discounts.where(['code ilike ? '] + Array.new(1, "%#{@search_text}%")) if @search_text.present?
    filter_discount_ids = []
    @filters.each do |filter|
      if filter.key.to_sym == :item_code
        filter_discount_ids << DiscountFilter.where(filter_key: 'item',
                                                    value: filter.value).distinct(:discount_id).pluck(:discount_id)
      elsif filter.key.to_sym == :item_type_name
        filter_discount_ids << DiscountFilter.where(filter_key: 'item_type',
                                                    value: filter.value).distinct(:discount_id).pluck(:discount_id)
      elsif filter.key.to_sym == :supplier_code
        filter_discount_ids << DiscountFilter.where(filter_key: 'supplier',
                                                    value: filter.value).distinct(:discount_id).pluck(:discount_id)
      elsif filter.key.to_sym == :brand_name
        filter_discount_ids << DiscountFilter.where(filter_key: 'brand',
                                                    value: filter.value).distinct(:discount_id).pluck(:discount_id)
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
      discounts.order(@sort)
    else
      discounts.order(id: :asc)
    end
  end
end
