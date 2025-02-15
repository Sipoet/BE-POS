class Ipos::Supplier < Ipos::Supel
  TABLE_HEADER = [
    datatable_column(self,:kode, :string),
    datatable_column(self,:nama, :string),
    datatable_column(self,:alamat, :string),
    datatable_column(self,:kontak, :string),
    datatable_column(self,:email, :string),
    datatable_column(self,:bank, :string),
    datatable_column(self,:norek, :string),
    datatable_column(self,:atasnama, :string),
    datatable_column(self,:keterangan, :string),
  ]

  def self.sti_name
    'SU'
  end

  after_update do |record|
    Cache.delete("supplier-serializer:ipos/suppliers/#{record.kode}")
  end

end
