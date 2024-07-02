class Payroll::Formula::ProportionalCommissionCalculator < Payroll::Formula::ApplicationCalculator

  # variable1 type commission based, 1 is total sales, 2 is gross profit
  # setting key 'percentage_commission_type_[x]' is value of percentage based x type
  # variable2 indicator multiplier after divide proportional. if value is 1, no multiplying .default is 1
  # variable3 is logic shared commission type, 1 based attendance day, 2 is group based shift, 3 is individual, default is 1
  def calculate
    commission_total_type = payroll_line.variable1.to_i
    percentage = Setting.get("percentage_commission_type#{commission_total_type}") || 0
    logic_shared_type = payroll_line.variable3 || 1
    return comission_individual(percentage) if logic_shared_type == 3
    multiplier = payroll_line.variable2 || 1
    total_commission = 0
    calculated_key = total_based_type_key
    return 0 if attendance_summary.is_last_work
    attendance_summary.details.each do |detail|
      next if detail.work_hours <= 0
      date = detail.date
      result = commission_analyzer.result_of(date)
      total_people = if logic_shared_type == 2
        result.total_people_per_shift[detail.shift] || 0
      elsif logic_shared_type == 1
        result.total_people
      else
        result.total_people
      end
      next if total_people == 0
      total = result.send(calculated_key)
      commission_per_day = percentage * total / (100.0 * total_people)
      total_commission += commission_per_day.round(-2)
    end
    total_commission
  end

  private

  def comission_individual(percentage)
    # not implemented
    # sale = Sale.where(date: attendance_summary.start_date..(attendance_summary.end_date))
    # SalesItem.where(employee_id: employee.id, sale: sale)
    #          .sum(:gross_profit)
  end

  def total_people_of(employee_ids,date, shift: nil)
    query = if shift.nil?
      EmployeeAttendance.where(date: date, employee_id: employee_ids)
    else
      EmployeeAttendance.where(date: date, employee_id: employee_ids, shift: shift)
    end
    query.distinct(:employee_id).count
  end

  def total_based_type_key
    if payroll_line.variable1 == 1
      :gross_sales
    elsif payroll_line.variable1 == 2
      :gross_profit
    end
  end

  def cogs_total_of(sales)
    Ipos::SaleItem.where(sale: sales)
                  .includes(:item)
                  .sum("#{Ipos::Item.table_name}.hargapokok * #{Ipos::SaleItem.table_name}.jumlah")
  end

  def total_sales_people_on(shift:,date:)
    EmployeeAttendance.where(shift: 1,date: date,).distinct(&:employee_id).count
  end


end
