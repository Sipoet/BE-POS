class Account::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    account = Ipos::Account.find(params[:id])
    raise RecordNotFound.new(params[:id], Ipos::Account.model_name.human) if account.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::AccountSerializer.new(account, options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Account)
    allowed_fields = [:account]
    result = dezerialize_table_params(params,
                                      allowed_fields: allowed_fields,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = result.fields
  end
end
