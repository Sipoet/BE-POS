class Bank::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @banks = find_banks
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(BankSerializer.new(@banks, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @banks.total_pages,
      total_rows: @banks.total_count
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::Bank)
    allowed_includes = [:bank]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Bank)
  end

  def find_banks
    banks = Ipos::Bank.all.includes(@included)
                      .page(@page)
                      .per(@limit)
    if @search_text.present?
      banks = banks.where(['kodebank ilike ?  or namabank ilike ?'] + Array.new(2, "%#{@search_text}%"))
    end
    @filters.each do |filter|
      banks = banks.where(filter.to_query)
    end
    if @sort.present?
      banks.order(@sort)
    else
      banks.order(kodebank: :asc)
    end
  end
end
