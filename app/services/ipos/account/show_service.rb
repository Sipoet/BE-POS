class Ipos::Account::ShowService < ApplicationService
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
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::Account)
    allowed_includes = [:account]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Account)
  end
end
