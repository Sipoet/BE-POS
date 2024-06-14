require 'cgi'
class Transfer::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    transfer = Ipos::Transfer.find(@code)
    raise RecordNotFound.new(@code,Ipos::Transfer.model_name.human) if transfer.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::TransferSerializer.new(transfer,options))
  end

  def extract_params
    allowed_columns = Ipos::Transfer::TABLE_HEADER.map(&:name)
    allowed_fields = [:tranfer,:transfer_items,'transfer_items.item']
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @included = result.included
    @fields = result.fields
    @code = CGI.unescape(params[:code])
  end

end
