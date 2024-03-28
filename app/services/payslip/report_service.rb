class Payslip::ReportService < ApplicationService

  def execute_service
    extract_params
    payslips = find_payslips
    results = payslips.map{|payslip|decorate_payslip(payslip)}
    response_type = find_response_type

    case response_type
    when 'excel'
      excel_response(results)
    when 'json'
      json_response(results)
    else
      json_response(results)
    end
  rescue ExpectedError => e
    render_json({message: e.message}, {status: :conflict})
  end
  private

  def json_response(results)
    render_json(PayslipReportSerializer.new(results, include: @included, params:{include:@included}))
  end

  def excel_response(results)
    generator = ExcelGenerator.new
    generator.add_column_definitions(PayslipReport::TABLE_HEADER)
    generator.add_data(results)
    generator.add_metadata({start_date: @start_date,end_date: @end_date, employee_ids: @employee_ids.try(:join,',')})
    file_excel = generator.generate("payslip_report-#{@start_date.iso8601}-#{@end_date.iso8601}")
    @controller.send_file file_excel
  end

  def decorate_payslip(payslip)
    result = PayslipReport.new
    result.start_date = payslip.start_date
    result.end_date = payslip.end_date
    result.employee_id = payslip.employee_id
    result.payslip_id = payslip.id
    result.late = 0
    employee = payslip.employee
    if employee.present?
      result.employee_name = employee.name
      result.employee_start_working_date = employee.start_working_date
      result.bank = employee.bank
      result.bank_account = employee.bank_account
      result.bank_register_name = employee.bank_register_name
    end
    payslip_lines = payslip.payslip_lines
    result.total_day = payslip.total_day
    result.work_days = payslip.work_days
    result.sick_leave = payslip.sick_leave
    result.overtime_hour = payslip.overtime_hour
    result.known_absence = payslip.known_absence
    result.unknown_absence = payslip.unknown_absence
    result.positional_incentive = 0
    result.attendance_incentive = 0
    result.other_incentive = 0
    result.base_salary = 0
    result.debt = 0
    result.overtime_incentive = 0


    payslip_lines.each do |payslip_line|
      if payslip_line.incentive?
        if payslip_line.description.downcase.include?('jabatan')
          result.positional_incentive += payslip_line.amount
        elsif payslip_line.description.downcase.include?('kerajinan')
          result.attendance_incentive += payslip_line.amount
        elsif payslip_line.description.downcase.include?('overtime')
          result.overtime_incentive += payslip_line.amount
        else
          result.other_incentive += payslip_line.amount
        end
      elsif payslip_line.base_salary?
        result.base_salary += payslip_line.amount
      elsif payslip_line.debt?
        result.debt += payslip_line.amount
      end
    end
    result.tax_amount = payslip.tax_amount
    result.nett_salary = payslip.nett_salary
    result
  end

  def find_response_type
    response_types = @controller.request.headers['Accept']
    return 'json' if response_types.nil?
    response_types = response_types.split(',')
    response_types.each do |response_type|
      return 'json' if ['application/json','application/vnd.api+json'].include?(response_type.strip)
      return 'excel' if ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet','application/vnd.ms-excel'].include?(response_type.strip)
    end
  end

  def extract_params
    permitted_params = params.required(:filter)
                             .permit(:start_date,:end_date,:employee_ids)
    @start_date = permitted_params[:start_date].try(:to_date)
    @end_date = permitted_params[:end_date].try(:to_date)
    if @start_date.blank? || @end_date.blank?
      raise ExpectedError.new('tanggal mulai dan tanggal akhir harus dipilih')
    end
    @employee_ids = permitted_params[:employee_ids]
    return if @employee_ids.blank?
    @employee_ids = @employee_ids.split(',').map(&:to_i)
  end

  def find_payslips
    query = Payslip.where('start_date <= ? AND end_date >= ?',@end_date,@start_date)
                  .includes(:payslip_lines,:employee)
                  .order('employees.name' => :asc)
    if @employee_ids.present?
      query = query.where(employee_id: @employee_ids)
    end
    query
  end
  class ExpectedError < StandardError; end
end
