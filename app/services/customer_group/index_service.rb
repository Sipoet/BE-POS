class CustomerGroup::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @customer_groups = find_customer_groups
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(CustomerGroupSerializer.new(@customer_groups, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @customer_groups.total_count,
      total_pages: @customer_groups.total_pages
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::CustomerGroup)
    allowed_includes = [:customer_group]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::CustomerGroup)
  end

  def find_customer_groups
    customer_groups = Ipos::CustomerGroup.all.includes(@included)
                                         .page(@page)
                                         .per(@limit)
    if @search_text.present?
      customer_groups = customer_groups.where(['grup ilike ? '] + Array.new(1, "%#{@search_text}%"))
    end
    @filters.each do |filter|
      customer_groups = customer_groups.where(filter.to_query)
    end
    if @sort.present?
      customer_groups.order(@sort)
    else
      customer_groups.order(id: :asc)
    end
  end
end
