require 'cgi'
class Transfer::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    transfer = Ipos::Transfer.find(@code)
    raise RecordNotFound.new(@code, Ipos::Transfer.model_name.human) if transfer.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::TransferSerializer.new(transfer, options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Transfer)
    allowed_includes = [:tranfer, :transfer_items, 'transfer_items.item']
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Transfer)
    @code = CGI.unescape(params[:code])
  end
end
