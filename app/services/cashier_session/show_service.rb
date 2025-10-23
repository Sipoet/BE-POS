class CashierSession::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    cashier_session = if params[:id] == 'today'
                        CashierSession.today_session
                      else
                        CashierSession.find(params[:id])
                      end
    raise RecordNotFound.new(params[:id], CashierSession.model_name.human) if cashier_session.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(CashierSessionSerializer.new(cashier_session, options))
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(CashierSession)
    allowed_includes = %i[cashier_session edc_settlements]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: CashierSession)
  end
end
