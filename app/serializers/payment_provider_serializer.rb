class PaymentProviderSerializer
  include JSONAPI::Serializer
  attributes :bank_or_provider, :name, :currency, :account_number,
              :account_register_name, :created_at, :updated_at,
              :swift_code,:status

  has_many :payment_provider_edcs, if: Proc.new { |record, params| params[:include].include?('payment_provider_edcs') rescue false }

  cache_options store: Rails.cache, namespace: 'payment_provider-serializer', expires_in: 1.hour
end
