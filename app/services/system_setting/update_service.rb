class SystemSetting::UpdateService < ApplicationService
  def execute_service
    setting = Setting.find(params[:id])
    raise RecordNotFound.new(params[:id], Setting.model_name.human) if setting.nil?

    if record_save?(setting)
      render_json(SystemSettingSerializer.new(setting, { fields: @fields }))
    else
      render_error_record(setting)
    end
  end

  def record_save?(setting)
    ApplicationRecord.transaction do
      update_attribute(setting)
      setting.save!
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def update_attribute(setting)
    @table_definition = Datatable::DefinitionExtractor.new(Setting)
    @fields = { setting: permitted_column_names(Setting, nil) }
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(:value, :user_id, :value_type)
    setting.user_id = permitted_params[:user_id]
    setting.value = {
      data: permitted_params[:value],
      value_type: permitted_params[:value_type] || value_type_of(permitted_params[:value])
    }.to_json
  end

  def value_type_of(value)
    if value.is_a?(String)
      :string
    elsif value.is_a?(Numeric)
      :number
    elsif [true, false].include?(value)
      :boolean
    elsif value.is_a?(Array)
      :array
    elsif value.is_a?(Hash)
      :hash
    else
      value.class.to_s
    end
  end
end
