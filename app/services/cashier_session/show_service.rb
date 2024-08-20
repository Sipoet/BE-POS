class CashierSession::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    cashier_session = if params[:id] == 'today'
      CashierSession.today.first
    else
      CashierSession.find(params[:id])
    end
    raise RecordNotFound.new(params[:id],CashierSession.model_name.human) if cashier_session.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(CashierSessionSerializer.new(cashier_session,options))
  end

  def extract_params
    allowed_columns = CashierSession::TABLE_HEADER.map(&:name)
    allowed_fields = [:cashier_session,:edc_settlements]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @included = result.included
    @fields = result.fields
  end

end
