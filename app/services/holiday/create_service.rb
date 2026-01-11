class Holiday::CreateService < ApplicationService
  def execute_service
    holiday = Holiday.new
    if record_save?(holiday)
      render_json(HolidaySerializer.new(holiday, fields: @fields), { status: :created })
    else
      render_error_record(holiday)
    end
  end

  def record_save?(holiday)
    ApplicationRecord.transaction do
      update_attribute(holiday)
      holiday.save!
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def update_attribute(holiday)
    @table_definition = Datatable::DefinitionExtractor.new(Holiday)
    @fields = { holiday: permitted_column_names(Holiday, nil) }
    permitted_columns = permitted_edit_columns(Holiday, @table_definition.allowed_edit_columns)
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(permitted_columns)
    holiday.attributes = permitted_params
  end
end
