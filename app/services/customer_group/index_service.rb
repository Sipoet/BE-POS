class CustomerGroup::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @customer_groups = find_customer_groups
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(CustomerGroupSerializer.new(@customer_groups,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @customer_groups.count,
       total_pages: @customer_groups.total_pages,
    }
  end

  def extract_params
    allowed_columns = Ipos::CustomerGroup::TABLE_HEADER.map(&:name)
    allowed_fields = [:customer_group]
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

  def find_customer_groups
    customer_groups = Ipos::CustomerGroup.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      customer_groups = customer_groups.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      customer_groups = customer_groups.where(filter.to_query)
    end
    if @sort.present?
      customer_groups = customer_groups.order(@sort)
    else
      customer_groups = customer_groups.order(id: :asc)
    end
    customer_groups
  end

end
