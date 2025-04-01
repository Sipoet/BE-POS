class CommissionAnalyzer
  attr_reader :start_date, :end_date

  def initialize(start_date:,end_date:)
    @start_date = start_date
    @end_date = end_date
  end

  def analyze
    @result_by_date = analyze_by_date
    analyze_by_employee
  end

  def result_of(date)
    @result_by_date[date]
  end

  def result_of_employee(employee_id)
    @result_by_employee[employee_id]
  end

  private

  def analyze_by_employee
    @result_by_employee = {}
    payroll_ids = PayrollLine.where(formula: :proportional_commission).pluck(:payroll_id)
    employee_ids = EmployeeAttendance.where(date: @start_date..@end_date).pluck(:employee_id)
    employee_ids = Employee.where(payroll_id: payroll_ids, id: employee_ids)
                           .pluck(:id)
    employee_ids.each do |employee_id|
      @result_by_employee[employee_id] = EmployeeResult.new(employee_id: employee_id)
    end

    sales = Ipos::Sale.where(tanggal: start_date.beginning_of_day..(@end_date.end_of_day),
                             tipe:['KSR','JL'])
    sales.each do |sale|
      sale_calculate_result(sale)
    end
  end

  def sale_calculate_result(sale)
    employee_ids = EmployeeAttendance.where("'#{sale.tanggal}' BETWEEN start_time AND end_time")
                                    .where(employee_id: @result_by_employee.keys)
                                    .pluck(:employee_id)
    total_people = employee_ids.length
    cogs_total = sale.sale_items
                     .joins(:item)
                     .sum("#{Ipos::Item.table_name}.hargapokok * #{Ipos::SaleItem.table_name}.jumlah")
    gross_sales = sale.totalakhir
    gross_profit = gross_sales - cogs_total
    employee_ids.each do |employee_id|
      result = @result_by_employee[employee_id]
      result.gross_sales += gross_sales / total_people
      result.cogs_total += cogs_total / total_people
      result.gross_profit += gross_profit / total_people
    end
  end

  def analyze_by_date
    results = {}
    (@start_date..@end_date).each do |date|
      sales = Ipos::Sale.where(tanggal: date.beginning_of_day..(date.end_of_day),tipe: 'KSR')
      gross_sales = gross_sales_of(sales)
      cogs_total = cogs_total_of(sales)
      result = Result.new(
        gross_sales: gross_sales,
        cogs_total: cogs_total,
        gross_profit: gross_sales - cogs_total,
        date: date
      )
      insert_shift_results(result)
      total_people_per_shift = total_people_of(date)
      results[date] = result
    end
    results
  end

  def insert_shift_results(result)
    payroll_ids = PayrollLine.where(formula: :proportional_commission).pluck(:payroll_id)
    employee_ids = Employee.where(payroll_id: payroll_ids).pluck(:id)
    date = result.date
    query = EmployeeAttendance.where(date: date, employee_id: employee_ids)
    query.distinct.pluck(:shift).each do |shift|
      shift_alias = shift.to_i == 1 ? 'PAGI' : 'MALAM'
      total_people = query.where(shift: shift)
                          .distinct
                          .count(:employee_id)
      sales = Ipos::Sale.where(tanggal: date.beginning_of_day..(date.end_of_day),
                               shiftkerja: shift_alias)
      gross_sales = gross_sales_of(sales)

      cogs_total = cogs_total_of(sales)
      result.add_shift(shift,{
        total_people: total_people,
        gross_sales: gross_sales,
        cogs_total: cogs_total,
        gross_profit: gross_sales - cogs_total,
      })
    end
  end

  def total_people_of(date)
  end

  def gross_sales_of(sales)
    sales.sum(:totalakhir)
  end

  def cogs_total_of(sales)
    Ipos::SaleItem.where(sale: sales)
                  .includes(:item)
                  .sum("#{Ipos::Item.table_name}.hargapokok * #{Ipos::SaleItem.table_name}.jumlah")
  end

  class Result
    attr_accessor :employee_id,
                  :gross_sales,
                  :cogs_total,
                  :gross_profit,
                  :date
    attr_reader  :result_per_shift

    def initialize(options)
      options.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
      @result_per_shift ||= {}
    end

    def add_shift(shift,options)
      result= ShiftResult.new(options)
      result.shift = shift
      @result_per_shift[shift] = result
    end

    def total_people
      @result_per_shift.values.sum(&:total_people)
    end
  end

  class EmployeeResult
    attr_accessor :employee_id,
                  :gross_sales,
                  :cogs_total,
                  :gross_profit

    def initialize(options)
      @employee_id = options[:employee_id]
      @gross_sales = 0
      @cogs_total = 0
      @gross_profit = 0
    end
end

  class ShiftResult
    attr_accessor :gross_sales,
                  :cogs_total,
                  :gross_profit,
                  :total_people,
                  :shift

    def initialize(options)
      options.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
    end
  end
end
