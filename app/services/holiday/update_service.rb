class Holiday::UpdateService < ApplicationService

  def execute_service
    holiday = Holiday.find(params[:id])
    raise RecordNotFound.new(params[:id],Holiday.model_name.human) if holiday.nil?
    if record_save?(holiday)
      render_json(HolidaySerializer.new(holiday,{fields: @fields}))
    else
      render_error_record(holiday)
    end
  end

  def record_save?(holiday)
    ApplicationRecord.transaction do
      update_attribute(holiday)
      holiday.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def update_attribute(holiday)
    @table_definitions = Datatable::DefinitionExtractor.new(Holiday)
    @fields = {holiday: @table_definitions.allowed_columns}
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(@table_definitions.allowed_columns)
    holiday.attributes = permitted_params
  end
end
