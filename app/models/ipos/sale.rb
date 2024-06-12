class Ipos::Sale < ApplicationRecord
  self.table_name = 'tbl_ikhd'
  self.primary_key = 'notransaksi'

  TABLE_HEADER = [
    datatable_column(self,:notransaksi, :string),
    datatable_column(self,:tanggal, :datetime),
    datatable_column(self,:totalitem, :decimal),
    datatable_column(self,:subtotal, :decimal),
    datatable_column(self,:potnomfaktur, :decimal),
    datatable_column(self,:biayalain, :decimal),
    datatable_column(self,:pajak, :decimal),
    datatable_column(self,:totalakhir, :decimal),
    datatable_column(self,:payment_type, :string),
    datatable_column(self,:bank_code, :string),
    datatable_column(self,:jmltunai, :decimal),
    datatable_column(self,:jmldebit, :decimal),
    datatable_column(self,:jmlkk, :decimal),
    datatable_column(self,:jmlemoney, :decimal),
    datatable_column(self,:keterangan, :string),
    datatable_column(self,:user1, :string),
    datatable_column(self,:ppn, :string),

  ].freeze

  has_many :sale_items, class_name: 'Ipos::SaleItem',foreign_key: :notransaksi, dependent: :destroy, inverse_of: :sale
  belongs_to :credit_bank, optional: true, primary_key: 'kodebank',class_name: 'Ipos::Bank',foreign_key:'byr_kk_bank'
  belongs_to :debit_bank, optional: true, primary_key: 'kodebank',class_name: 'Ipos::Bank',foreign_key:'byr_debit_bank'

  def bank_code
    byr_kk_bank || byr_debit_bank
  end

  def payment_type
    if jmlemoney > 0
      byr_emoney_prod
    elsif jmltunai > 0
      'Tunai'
    elsif jmldebit > 0
      'Kartu Debit'
    elsif jmlkk > 0
      'Kartu Kredit'
    else
      'unknown'
    end
  end

  def bank
    debit_bank || credit_bank
  end

  def self.sti_name
    ['KSR','JL']
  end
end
