class EdcSettlement::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @edc_settlements = find_edc_settlements
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(EdcSettlementSerializer.new(@edc_settlements,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @edc_settlements.total_count,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(EdcSettlement)
    allowed_fields = [:edc_settlement,:payment_provider,:payment_type,:cashier_session]
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

  def find_edc_settlements
    edc_settlements = EdcSettlement.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      edc_settlements = edc_settlements.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      edc_settlements = edc_settlements.where(filter.to_query)
    end
    if params[:cashier_session_id].present?
      edc_settlements = edc_settlements.where(cashier_session_id: params[:cashier_session_id])
    end
    if @sort.present?
      edc_settlements = edc_settlements.order(@sort)
    else
      edc_settlements = edc_settlements.order(id: :asc)
    end
    edc_settlements
  end

end
