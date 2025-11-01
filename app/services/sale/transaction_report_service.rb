class Sale::TransactionReportService < ApplicationService
  include TransactionReportFinder
  def execute_service
    sales_transaction_report = summary_sales_transaction(start_time: start_time,
                                                         end_time: end_time)
    render_json(SalesTransactionReportSerializer.new(sales_transaction_report))
  end

  private

  def start_time
    @start_time ||= @params.fetch(:start_time, DateTime.parse("#{Date.today}Z")).try(:to_time)
  end

  def end_time
    @end_time ||= @params.fetch(:end_time, DateTime.parse("#{Date.today}Z").end_of_day).try(:to_time)
  end
end
