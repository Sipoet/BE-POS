class EdcSettlement < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:payment_provider, :link,path: 'payment_providers', attribute_key:'payment_provider.code'),
    datatable_column(self,:payment_type, :link,path: 'payment_types', attribute_key:'payment_type.name'),
    datatable_column(self,:status, :enum),
    datatable_column(self,:amount, :decimal),
    datatable_column(self,:diff_amount, :decimal),
    datatable_column(self,:merchant_id, :string),
    datatable_column(self,:terminal_id, :string),
    datatable_column(self,:created_at, :datetime),
    datatable_column(self,:updated_at, :datetime),
  ]

  enum :status,{
    draft:0,
    verified:1,
  }

  validates :amount, numericality:{greater_than: 0}, presence: true
  validates :diff_amount, numericality:{greater_than_and_equal_to: 0}, presence: true
  validates :status, presence: true

  belongs_to :cashier_session, inverse_of: :edc_settlements
  belongs_to :payment_type
  belongs_to :payment_provider
end
