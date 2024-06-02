class Ipos::Supplier < Ipos::Supel
  TABLE_HEADER = [
    datatable_column(self,:kode, :string),
    datatable_column(self,:nama, :string),
  ]

  def self.sti_name
    'SU'
  end


end
