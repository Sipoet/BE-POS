class Ipos::Purchase < Ipos::ItemInHeader

  TABLE_HEADER = [
    datatable_column(self, :notransaksi, :string),
    datatable_column(self, :kodesupel, :link, path: 'suppliers', attribute_key:'supplier.nama'),
    datatable_column(self, :notrsorder, :string),
    datatable_column(self, :tanggal, :datetime),
    datatable_column(self, :kantortujuan, :string),
    datatable_column(self, :totalitem, :decimal),
    datatable_column(self, :subtotal, :decimal),
    datatable_column(self, :potnomfaktur, :decimal),
    datatable_column(self, :biayalain, :decimal),
    datatable_column(self, :ppn, :string),
    datatable_column(self, :pajak, :decimal),
    datatable_column(self, :totalakhir, :decimal),
    datatable_column(self, :keterangan, :string),
    datatable_column(self, :user1, :string),
    datatable_column(self, :jmltunai, :decimal),
    datatable_column(self, :jmlkredit, :decimal),
    datatable_column(self, :jmldeposit, :decimal),
  ].freeze

  has_many :purchase_items, class_name:'Ipos::PurchaseItem',  foreign_key: 'notransaksi', primary_key: 'notransaksi',dependent: :destroy
  belongs_to :purchase_order, class_name: 'Ipos::PurchaseOrder', foreign_key: 'notrsorder', primary_key: 'notransaksi'

  def self.sti_name
    'BL'
  end
end
