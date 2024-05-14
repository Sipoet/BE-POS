class History::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @histories = find_histories
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(HistorySerializer.new(@histories,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @histories.total_pages,
    }
  end

  def extract_params
    allowed_columns = History::TABLE_HEADER.map(&:name)
    allowed_fields = [:history]
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

  def find_histories
    histories = History.all.includes(@included)
      .page(@page)
      .per(@limit)
    @filters.each do |filter|
      histories = histories.where(filter.to_query)
    end
    if @sort.present?
      histories = histories.order(@sort)
    else
      histories = histories.order(created_at: :desc)
    end
    histories
  end

end
