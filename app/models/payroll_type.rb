class PayrollType < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:name, :string),
    datatable_column(self,:initial, :string),
    datatable_column(self,:order, :integer),
    datatable_column(self,:is_show_on_payslip_desc, :boolean),
    datatable_column(self,:created_at, :datetime),
    datatable_column(self,:updated_at, :datetime),
  ].freeze

  validates :name, presence: true
  validates :initial, presence: true
  validates :order, presence: true, numericality:{greater_than: 0,integer: 0}
end
