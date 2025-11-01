class Ipos::Sale < Ipos::ItemOutHeader
  has_many :sale_items, class_name: 'Ipos::SaleItem', foreign_key: :notransaksi, dependent: :destroy, inverse_of: :sale
  belongs_to :credit_bank, optional: true, primary_key: 'kodebank', class_name: 'Ipos::Bank', foreign_key: 'byr_kk_bank'
  belongs_to :debit_bank, optional: true, primary_key: 'kodebank', class_name: 'Ipos::Bank',
                          foreign_key: 'byr_debit_bank'

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
    %w[KSR JL]
  end
end
