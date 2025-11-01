class EdcSettlementSerializer
  include JSONAPI::Serializer
  attributes :status, :amount, :diff_amount, :merchant_id, :terminal_id,
             :created_at, :updated_at

  belongs_to :payment_provider, if: proc { |_record, params|
    begin
      params[:include].include?('payment_provider')
    rescue StandardError
      false
    end
  }
  belongs_to :payment_type, if: proc { |_record, params|
    begin
      params[:include].include?('payment_type')
    rescue StandardError
      false
    end
  }
  belongs_to :cashier_session, if: proc { |_record, params|
    begin
      params[:include].include?('cashier_session')
    rescue StandardError
      false
    end
  }
end
