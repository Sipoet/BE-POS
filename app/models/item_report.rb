class ItemReport < ApplicationRecord
  self.table_name = 'item_sales_percentage_reports'
  self.primary_key = 'item_code'


  belongs_to :item, foreign_key: :item_code, primary_key: :kodeitem, class_name:'Ipos::Item'
  belongs_to :item_type, foreign_key: :item_type_name, primary_key: :jenis, class_name:'Ipos::ItemType'
  belongs_to :brand, optional: true, foreign_key: :brand_name, primary_key: :merek, class_name:'Ipos::Brand'
  belongs_to :supplier, foreign_key: :supplier_code, primary_key: :kode, class_name:'Ipos::Supplier'

  alias_attribute :id, :item_code

  def readonly?
    true
  end

end
