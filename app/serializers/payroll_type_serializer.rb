class PayrollTypeSerializer
  include JSONAPI::Serializer
  attributes :name, :order, :initial, :is_show_on_payslip_desc,
             :created_at, :updated_at
end
