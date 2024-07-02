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
      total_people_per_shift = total_people_of(date)
      results[date] = Result.new(
        gross_sales: gross_sales,
        cogs_total: cogs_total,
        gross_profit: gross_sales - cogs_total,
        total_people_per_shift: total_people_per_shift
      )
    end
    results
  end

  def total_people_of(date)
    payroll_ids = PayrollLine.where(formula: :proportional_commission).pluck(:payroll_id)
    employee_ids = Employee.where(payroll_id: payroll_ids).pluck(:id)
    query = EmployeeAttendance.where(date: date, employee_id: employee_ids)

    query.distinct.pluck(:shift).each_with_object({}) do|shift, obj|
      obj[shift] = query.where(shift: shift)
                        .distinct
                        .count(:employee_id)
    end


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
                  :shift,
                  :date,
                  :total_people_per_shift
    def initialize(options)
      options.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
    end

    def total_people
      total_people_per_shift.values.sum
    end
  end
end
