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
    meta= {
      table_columns: table_columns
    }
    render_json(PayslipReportSerializer.new(results, include: @included,meta: meta, params:{include:@included, payroll_types: @payroll_types}))
  end

  def excel_response(results)
    generator = ExcelGenerator.new
    generator.set_row_data_type_hash!
    generator.add_column_definitions(table_columns)
    generator.add_data(results)
    generator.add_metadata({start_date: @start_date,end_date: @end_date, employee_ids: @employee_ids.try(:join,',')})
    file_excel = generator.generate("laporan-slip-gaji-#{@start_date.strftime('%d%b%y')}-#{@end_date.strftime('%d%b%y')}-")
    @controller.send_file file_excel
  end

  def table_columns
    result = [
      Datatable::TableColumn.new(
      :employee_name,
      {
        humanize_name: PayslipReport.human_attribute_name(:employee_name),
        type: :model,
        input_options:
          path: 'employees',
          model_name:'employee'
          attribute_key: 'employee_name',
        sort_key: 'employee_name'
      }),
      Datatable::TableColumn.new(
      :employee_start_working_date,
      {
        humanize_name: PayslipReport.human_attribute_name(:employee_start_working_date),
        type: :date,
        width:14
      }),
      Datatable::TableColumn.new(
      :start_date,
      {
        humanize_name: PayslipReport.human_attribute_name(:start_date),
        type: :date,
        width:14
      }),
      Datatable::TableColumn.new(
      :end_date,
      {
        humanize_name: PayslipReport.human_attribute_name(:end_date),
        type: :date,
         width:15
      }
      ),
      Datatable::TableColumn.new(
      :work_days,
      {
        humanize_name: PayslipReport.human_attribute_name(:work_days),
        type: :decimal,
         width:10}),
      Datatable::TableColumn.new(
      :total_day,
      {
        humanize_name: PayslipReport.human_attribute_name(:total_day),
        type: :integer,
        width:10}),
      Datatable::TableColumn.new(
      :overtime_hour,
      {
        humanize_name: PayslipReport.human_attribute_name(:overtime_hour),
        type: :integer,
         width:10}),
      Datatable::TableColumn.new(
      :late,
      {
        humanize_name: PayslipReport.human_attribute_name(:late),
        type: :integer,
         width:5}),
      Datatable::TableColumn.new(
      :sick_leave,
      {
        humanize_name: PayslipReport.human_attribute_name(:sick_leave),
        type: :integer,
        width:5}),
      Datatable::TableColumn.new(
      :known_absence,
      {
        humanize_name: PayslipReport.human_attribute_name(:known_absence),
        type: :integer,
        width:4}),
      Datatable::TableColumn.new(
      :unknown_absence,
      {
        humanize_name: PayslipReport.human_attribute_name(:unknown_absence),
        type: :integer,
        width:5}),
  ]
  result += @payroll_types.map do |payroll_type|
    Datatable::TableColumn.new(
      payroll_type.id.to_s,{
      humanize_name: payroll_type.name,
      type: :decimal,
      width:12})
  end
  result += [
      Datatable::TableColumn.new(
      :nett_salary,
      {
        humanize_name: PayslipReport.human_attribute_name(:nett_salary),
        type: :decimal,
        width:12}),
      Datatable::TableColumn.new(
      :description,
      {
        humanize_name: PayslipReport.human_attribute_name(:description),
        type: :string,
        width:17}),
      Datatable::TableColumn.new(
      :bank,
      {
        humanize_name: PayslipReport.human_attribute_name(:bank),
        type: :string,
        width:6}),
      Datatable::TableColumn.new(
      :bank_account,
      {
        humanize_name: PayslipReport.human_attribute_name(:bank_account),
        type: :string,
        width:20}),
      Datatable::TableColumn.new(
      :bank_register_name,
      {
        humanize_name: PayslipReport.human_attribute_name(:bank_register_name),
        type: :string,
        width:35}),
    ]
    result
  end

  def decorate_payslip(payslip)
    result = PayslipReport.new
    result.start_date = payslip.start_date
    result.end_date = payslip.end_date
    result.employee_id = payslip.employee_id
    result.payslip_id = payslip.id
    employee = payslip.employee
    if employee.present?
      result.employee_name = employee.name
      result.employee_start_working_date = employee.start_working_date
      result.bank = employee.bank
      result.bank_account = employee.bank_account
      result.bank_register_name = employee.bank_register_name
    end
    payslip_lines = payslip.payslip_lines.group_by(&:payroll_type_id)
    result.total_day = payslip.total_day
    result.work_days = payslip.work_days
    result.sick_leave = payslip.sick_leave
    result.overtime_hour = payslip.overtime_hour
    result.known_absence = payslip.known_absence
    result.unknown_absence = payslip.unknown_absence
    result.late = payslip.late
    result.payroll_type_amounts = {}
    description_arr = []
    description_arr << "HK#{result.work_days}" if result.work_days > 0
    @payroll_types.each do |payroll_type|
      selecteds = payslip_lines[payroll_type.id]
      amount = if selecteds.nil?
        0
      else
        selecteds.sum(&:amount)
      end
      result.payroll_type_amounts[payroll_type.id.to_s] = amount
      if amount > 0 && payroll_type.is_show_on_payslip_desc
        description_arr << "#{payroll_type.initial}#{amount_format(amount)}"
      end
    end
    result.nett_salary = payslip.nett_salary
    result.description = description_arr.join(',')
    result
  end

  def amount_format(amount)
    (amount/1000).floor.to_s
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
    @payroll_types = PayrollType.all.order(order: :asc) || []
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
