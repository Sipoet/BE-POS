# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# for development only
# puts 'seed user'
# User.transaction do
#   User.create!(username:'superadmin',email: 'fransiskus.r.sianto@gmail.com',password: ENV['ADMIN_PASSWORD'], password_confirmation:ENV['ADMIN_PASSWORD'], role: :superadmin)
#   User.create!(username:'marketing',email: 'allegra.dept.store@gmail.com',password: 'online2023allegra', password_confirmation: 'online2023allegra', role: :marketing)
#   User.create!(username:'kasir',email: 'kasir.allegra.dept.store@gmail.com',password: 'poskasir', password_confirmation: 'poskasir', role: :cashier)
#   User.create!(username:'gudang',email: 'gudang.allegra.dept.store@gmail.com',password: 'posgudang123', password_confirmation: 'posgudang123', role: :warehouse)
#   User.create!(username:'sales',email: 'sales.allegra.dept.store@gmail.com',password: 'possales', password_confirmation: 'possales', role: :sales)
# end
# puts 'seed user DONE'
start_time = 1.months.ago
end_time = 1.year.from_now
Discount.transaction do
  Discount.create(code: 'TEST-kodeitem1',item_code: Item.last.kodeitem,discount1: 1, start_time: start_time,end_time: end_time)
  Discount.create(code: 'TEST-kodesupplier1',supplier_code: Supplier.last.kode, discount1: 2, start_time: start_time,end_time: end_time)
  Discount.create(code: 'TEST-merek1',brand_name: Brand.last.merek,discount1: 3, start_time: start_time,end_time: end_time)
  Discount.create(code: 'TEST-jenis1',item_type: ItemType.last.jenis,discount1: 4, start_time: start_time,end_time: end_time)
  Discount.create(code: 'TEST-campur',supplier_code: Supplier.first.kode,item_type: ItemType.first.jenis,discount1: 5, start_time: start_time,end_time: end_time)
  Discount.create(code: 'TEST-disc1-4',brand_name: Brand.first.merek,discount1: 7,discount2: 8,discount3: 9, discount4: 10, start_time: start_time,end_time: end_time)
end
