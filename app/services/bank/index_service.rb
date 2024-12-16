class Bank::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @banks = find_banks
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(BankSerializer.new(@banks,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @banks.total_pages,
      total_rows: @banks.total_count,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Bank)
    allowed_fields = [:bank]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = result.fields
  end

  def find_banks
    banks = Ipos::Bank.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      banks = banks.where(['kodebank ilike ?  or namabank ilike ?']+ Array.new(2,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      banks = banks.where(filter.to_query)
    end
    if @sort.present?
      banks = banks.order(@sort)
    else
      banks = banks.order(kodebank: :asc)
    end
    banks
  end

end
