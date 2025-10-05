class Payroll::ReportService < ApplicationService

  def execute_service
    extract_params
    payroll_types = find_payroll_types
    table_columns = generate_table_columns(payroll_types)
    reports = generate_report(table_columns,payroll_types)
    case @report_type
    when 'xlsx'
      file_excel = generate_excel(table_columns,reports)
      @controller.send_file file_excel
    else
      options = {
        meta: {
          filter: {
            date: @date,
            payroll_type_ids: @payroll_type_ids
          },
          page: 1,
          limit: reports.length,
          table_columns: table_columns,
          total_rows: reports.length,
        },
        params:{
          payroll_types: payroll_types
        },
      }
      render_json(PayrollReportSerializer.new(reports, options))
    end
  end

  private

  def generate_table_columns(payroll_types)
    columns = [
      Datatable::TableColumn.new(
        :employee_name,
        {
          humanize_name: PayslipReport.human_attribute_name(:employee_name),
          type: :string,
          name: :employee_name,
          excel_width: 25,
          client_width: 200,

        }
      ),
      Datatable::TableColumn.new(
        :start_working_date,
        {
          humanize_name: Employee.human_attribute_name(:start_working_date),
          type: :date,
          name: :start_working_date,
          excel_width: 25,
          client_width: 200,
        }
      ),
      Datatable::TableColumn.new(
        :salary_total,
        {
          humanize_name: PayrollReport.human_attribute_name(:salary_total),
          type: :money,
          name: :salary_total,
          excel_width: 25,
          client_width: 200
        }
        )
    ]
    columns += payroll_types.map do |payroll_type|
      Datatable::TableColumn.new(
        payroll_type.id.to_s,
        {
          humanize_name: payroll_type.name,
          type: :money,
          name: payroll_type.id.to_s,
          excel_width: 25,
          client_width: 200
        }
        )
    end
    columns
  end

  def generate_report(table_columns,payroll_types)
    employees = Employee
      .where(start_working_date: ..@date,
             end_working_date: nil)
      .or(Employee.where(start_working_date: ..@date,
                end_working_date: @date..))
      .order(name: :asc)
    group_salary_details = find_salary_details(employees,payroll_types)
    employees.map do |employee|
      salary_details = group_salary_details[employee.payroll_id]
      salary_total = salary_details.sum(&:full_amount)
      PayrollReport.new(salary_details: salary_details,
                        employee_name: employee.name,
                        employee_id: employee.id,
                        start_working_date: employee.start_working_date,
                        salary_total: salary_total)
    end
  end

  def find_salary_details(employees, payroll_types)
    payroll_ids = employees.pluck(:payroll_id)
    group_payroll_type = payroll_types.index_by(&:id)
    PayrollLine
      .where(payroll_id: payroll_ids,
             payroll_type: payroll_types)
      .group_by(&:payroll_id)
      .each_with_object({}) do |(payroll_id,payroll_lines),obj|
        obj[payroll_id] = []
         payroll_lines.group_by(&:payroll_type_id).each do |payroll_type_id, payroll_lines|
          payroll_type = group_payroll_type[payroll_type_id]
          obj[payroll_id] << convert_to_report_detail(payroll_type,payroll_lines)
        end
      end
  end

  def convert_to_report_detail(payroll_type,payroll_lines)
    main_amount = 0
    full_amount = 0
    payroll_lines.each do |payroll_line|
      formula_calculator_class= Payroll::Calculator.calculator_class(payroll_line)
      payroll_line = payroll_line_from_date(payroll_line)
      main_amount += formula_calculator_class.main_amount(payroll_line)
      amount = formula_calculator_class.full_amount(payroll_line)
      full_amount += (payroll_line.earning? ? amount : amount * -1)
    end
    PayrollReportDetail.new(
      payroll_type_name: payroll_type.name,
      payroll_type_id: payroll_type.id,
      main_amount: main_amount,
      full_amount: full_amount,
      is_earning: full_amount >= 0
    )
  end

  def payroll_line_from_date(payroll_line)
    payroll_line.paper_trail.version_at(@date)
  end

  def find_payroll_types
    payroll_types = PayrollType.all
    if @payroll_type_ids.present?
      payroll_types = payroll_types.where(id: @payroll_type_ids)
    end
    payroll_types
  end

  def extract_params
    permitted_params = params.permit(:report_type,:date,payroll_type_ids:[])
    @date = Date.try(:parse, permitted_params[:date])
    @payroll_type_ids = *permitted_params[:payroll_type_ids]
    @report_type = permitted_params[:report_type].to_s
  end

  def generate_excel(table_columns,rows)
    generator = ExcelGenerator.new
    generator.set_row_data_type_hash!
    generator.add_column_definitions(table_columns)
    generator.add_data(rows)
    generator.add_metadata(@filter || {})
    generator.generate("laporan-payroll-#{@date}")
  end

end
