class PayrollSerializer
  include JSONAPI::Serializer
  attributes :name, :paid_time_off, :description,
             :created_at, :updated_at

  has_many :payroll_lines, if: proc { |_record, params|
    begin
      params[:include].include?('payroll_lines')
    rescue StandardError
      false
    end
  } do |payroll|
    payroll.payroll_lines.order(row: :asc)
  end
end
