class PayrollSerializer
  include JSONAPI::Serializer
  attributes :name, :paid_time_off, :description,
  :created_at, :updated_at

  has_many :payroll_lines, if: Proc.new { |record, params| params[:include].include?('payroll_lines') rescue false } do |payroll|
    payroll.payroll_lines.order(row: :asc)
  end

end
