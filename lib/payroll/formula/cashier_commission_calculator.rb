class Payroll::Formula::CashierCommissionCalculator < Payroll::Formula::ApplicationCalculator
  # variable1 min amount comission get
  # variable2 step multiplication amount based total sales user cashier
  # variable3 how much commission amount x1 multiplication
  # variable4 min amount added comission for value 1, replace by multiplication for value 2
  def calculate
    comission_calculator = choose_comission_calculator
    comission_total = 0
    grouped_cash_drawers.each do |date, values|
      sales_amount = values.sum { |line| line.cash_in }
      comission_amount = comission_calculator.call(sales_amount)
      comission_total += comission_amount
      Rails.logger.debug "date: #{date}, sales: #{sales_amount}, get comission: #{comission_amount}  total current commission: #{comission_total}"
    end
    comission_total
  end

  def self.main_amount(payroll_line)
    payroll_line.variable1 * 29
  end

  def self.full_amount(payroll_line)
    payroll_line.variable1 * 30
  end

  private

  def grouped_cash_drawers
    start_time = attendance_summary.start_date.beginning_of_day
    end_time = attendance_summary.end_date.end_of_day
    Ipos::CashDrawer.where(user_code: employee.user_code,
                           start_time: start_time..end_time)
                    .order(start_time: :asc)
                    .group_by { |line| line.start_time.to_date }
  end

  def choose_comission_calculator
    min_amount = payroll_line.variable1
    if payroll_line.variable4 = 2
      lambda { |sales_amount|
        amount = (sales_amount / payroll_line.variable2).floor * payroll_line.variable3
        amount == 0 ? min_amount : amount
      }
    elsif payroll_line.variable4 = 1
      lambda { |sales_amount|
        (sales_amount / payroll_line.variable2).floor * payroll_line.variable3 + min_amount
      }
    end
  end
end
