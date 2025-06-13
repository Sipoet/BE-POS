class Ipos::CashIn < Ipos::AccountCash

  def self.sti_name
    'KASI'
  end

  validates :kodekantor, presence: true
  validates :kodeacc, presence: true
  validates :tanggal, presence: true
  validates :matauang, presence: true
  validates :rate, presence: true

  validates :user1, presence: true
  validates :jumlah, presence: true
  validates :subtotal, presence: true
  validates :dateupd, presence: true
  validates :bc_trf_sts, presence: true


end
