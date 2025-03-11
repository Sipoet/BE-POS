class EdcSettlement < ApplicationRecord


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
