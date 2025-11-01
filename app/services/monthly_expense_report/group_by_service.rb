class MonthlyExpenseReport::GroupByService < ApplicationService
  def execute_service
    extract_params
    reports = find_reports
    render_json(MonthlyExpenseReportSerializer.new(reports))
  rescue ValidationError
    render_json({ message: 'Gagal Ambil Data', errors: @validator.errors.full_messages }, { status: :conflict })
  end

  private

  def find_reports
    range = @validator.start_date..(@validator.end_date)
    query = MonthlyExpenseReport.where(date_pk: range)
    if @validator.group_period == 'monthly'
      query.order(date_pk: :asc).to_a
    elsif @validator.group_period == 'yearly'
      query.group(:year).order(year: :asc).sum(:total).map do |year, total|
        MonthlyExpenseReport.new(date_pk: Date.new(year), year: year, total: total)
      end
    end
  end

  def extract_params
    permitted_params = params.permit(:group_period, :start_date, :end_date, account_codes: [])
    @validator = MonthlyExpenseReport::GroupByValidator.new(permitted_params)
    raise ValidationError unless @validator.valid?
  end
end
