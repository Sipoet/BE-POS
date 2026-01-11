class BookPayslipLine::UpdateService < ApplicationService
  def execute_service
    book_payslip_line = BookPayslipLine.find(params[:id])
    raise RecordNotFound.new(params[:id], BookPayslipLine.model_name.human) if book_payslip_line.nil?

    if record_save?(book_payslip_line)
      render_json(BookPayslipLineSerializer.new(book_payslip_line,
                                                { fields: @fields, include: %i[payroll_type employee] }))
    else
      render_error_record(book_payslip_line)
    end
  end

  def record_save?(book_payslip_line)
    ApplicationRecord.transaction do
      update_attribute(book_payslip_line)
      book_payslip_line.save!
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def update_attribute(book_payslip_line)
    @table_definition = Datatable::DefinitionExtractor.new(BookPayslipLine)
    @fields = { book_payslip_line: permitted_column_names(BookPayslipLine, nil) }
    permitted_columns = permitted_edit_columns(BookPayslipLine, @table_definition.allowed_edit_columns)
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(permitted_columns)
    book_payslip_line.attributes = permitted_params
  end
end
