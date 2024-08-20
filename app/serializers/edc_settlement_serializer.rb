class EdcSettlementSerializer
  include JSONAPI::Serializer
  attributes :status, :amount, :diff_amount, :merchant_id, :terminal_id,
            :created_at,:updated_at

  belongs_to :payment_provider, if: Proc.new { |record, params| params[:include].include?('payment_provider') rescue false }
  belongs_to :payment_type, if: Proc.new { |record, params| params[:include].include?('payment_type') rescue false }
  belongs_to :cashier_session, if: Proc.new { |record, params| params[:include].include?('cashier_session') rescue false }
end
