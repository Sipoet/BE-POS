class CustomerGroupDiscount::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @customer_group_discounts = find_customer_group_discounts
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(CustomerGroupDiscountSerializer.new(@customer_group_discounts, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @customer_group_discounts.total_count,
      total_pages: @customer_group_discounts.total_pages
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(CustomerGroupDiscount)
    allowed_includes = %i[customer_group_discount customer_group]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: CustomerGroupDiscount)
  end

  def find_customer_group_discounts
    customer_group_discounts = CustomerGroupDiscount.all.includes(@included)
                                                    .page(@page)
                                                    .per(@limit)
    if @search_text.present?
      customer_group_discounts = customer_group_discounts.where(['name ilike ? '] + Array.new(1, "%#{@search_text}%"))
    end
    @filters.each do |filter|
      customer_group_discounts = customer_group_discounts.where(filter.to_query)
    end
    if @sort.present?
      customer_group_discounts.order(@sort)
    else
      customer_group_discounts.order(id: :asc)
    end
  end
end
