class SupplierSerializer
  include JSONAPI::Serializer
  attributes :kode, :nama,:alamat,:kontak,:email,:bank,:norek,:atasnama,
            :keterangan

  cache_options store: Rails.cache, namespace: 'supplier-serializer', expires_in: 1.hour
end
