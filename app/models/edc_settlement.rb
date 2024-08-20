class EdcSettlement < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:cashier_session_id,:integer),
    datatable_column(self,:payment_provider_id, :link,path: 'payment_providers', attribute_key:'payment_provider.code'),
    datatable_column(self,:payment_type_id, :link,path: 'payment_types', attribute_key:'payment_type.name'),
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
  validates :diff_amount, numericality: true, presence: true
  validates :status, presence: true
  validates :terminal_id, presence: true,
                          uniqueness:{
                            scope:[:cashier_session_id,
                                    :payment_provider_id,
                                    :payment_type_id],
                            message:'duplikat'
                          }

  belongs_to :cashier_session, inverse_of: :edc_settlements
  belongs_to :payment_type
  belongs_to :payment_provider
end
