class PurchaseReport < ApplicationRecord

  self.table_name = 'purchase_reports'
  self.primary_key = 'code'


  belongs_to :supplier, foreign_key: :supplier_code, primary_key: :kode, class_name:'Ipos::Supplier'
  belongs_to :purchase, foreign_key: :code, primary_key: :notransaksi, class_name:'Ipos::Purchase'

  alias_attribute :id, :code

  def readonly?
    true
  end

  def self.refresh!
    connection.execute "REFRESH MATERIALIZED VIEW CONCURRENTLY purchase_reports"
  end

  def due_date
    attributes['due_date'].utc.to_date
  end

  [:purchase_date, :order_date, :shipping_date, :last_paid_date].each do |key|
    define_method(key) do
      datetime = self.attributes[key.to_s]
      return datetime if datetime.nil?
      Time.zone.parse(datetime.utc.iso8601.gsub('Z',''))
    end
  end

end
