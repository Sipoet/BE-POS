class PayrollType::UpdateService < ApplicationService
  def execute_service
    payroll_type = PayrollType.find(params[:id])
    raise RecordNotFound.new(params[:id], PayrollType.model_name.human) if payroll_type.nil?

    if record_save?(payroll_type)
      render_json(PayrollTypeSerializer.new(payroll_type, { fields: @fields }))
    else
      render_error_record(payroll_type)
    end
  end

  def record_save?(payroll_type)
    ApplicationRecord.transaction do
      update_attribute(payroll_type)
      payroll_type.save!
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def update_attribute(payroll_type)
    table_definitions = Datatable::DefinitionExtractor.new(PayrollType)
    allowed_columns = table_definitions.column_names
    @fields = { payroll_type: allowed_columns }
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(allowed_columns)
    payroll_type.attributes = permitted_params
  end
end
