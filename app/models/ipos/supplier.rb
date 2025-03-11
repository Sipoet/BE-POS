class Ipos::Supplier < Ipos::Supel

  def self.sti_name
    'SU'
  end

  after_update do |record|
    Cache.delete("supplier-serializer:ipos/suppliers/#{record.kode}")
  end

end
