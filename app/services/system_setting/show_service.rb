class SystemSetting::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    setting = Setting.find(params[:id])
    raise RecordNotFound.new(params[:id], Setting.model_name.human) if setting.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(SystemSettingSerializer.new(setting, options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Setting)
    allowed_includes = [:setting]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Setting)
  end
end
