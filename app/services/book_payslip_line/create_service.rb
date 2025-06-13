class BookPayslipLine::CreateService < ApplicationService

  def execute_service
    book_payslip_line = BookPayslipLine.new
    if record_save?(book_payslip_line)
      render_json(BookPayslipLineSerializer.new(book_payslip_line,fields:@fields,include: [:payroll_type,:employee]),{status: :created})
    else
      render_error_record(book_payslip_line)
    end
  end

  def record_save?(book_payslip_line)
    ApplicationRecord.transaction do
      update_attribute(book_payslip_line)
      book_payslip_line.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def update_attribute(book_payslip_line)
    @table_definitions = Datatable::DefinitionExtractor.new(BookPayslipLine)
    @fields = {book_payslip_line: @table_definitions.allowed_columns}
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(@table_definitions.allowed_edit_columns)
    book_payslip_line.attributes = permitted_params
  end

end
