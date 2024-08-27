class CommissionAnalyzer
  attr_reader :start_date, :end_date

  def initialize(start_date:,end_date:)
    @start_date = start_date
    @end_date = end_date
  end

  def analyze
    @result_by_date = analyze_by_date
    # @result_by_employee = analyze_by_employee
  end

  def result_of(date)
    @result_by_date[date]
  end

  private

  def analyze_by_date
    results = {}
    (@start_date..@end_date).each do |date|
      sales = Ipos::Sale.where(tanggal: date.beginning_of_day..(date.end_of_day))
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
