# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

puts 'seed user'
User.transaction do
  User.create!(username:'superadmin',email: 'fransiskus.r.sianto@gmail.com',password: ENV['ADMIN_PASSWORD'], password_confirmation:ENV['ADMIN_PASSWORD'], role: :superadmin)
  User.create!(username:'marketing',email: 'allegra.dept.store@gmail.com',password: 'online2023allegra', password_confirmation: 'online2023allegra', role: :marketing)
  User.create!(username:'kasir',email: 'kasir.allegra.dept.store@gmail.com',password: 'poskasir', password_confirmation: 'poskasir', role: :cashier)
  User.create!(username:'gudang',email: 'gudang.allegra.dept.store@gmail.com',password: 'posgudang123', password_confirmation: 'posgudang123', role: :warehouse)
  User.create!(username:'sales',email: 'sales.allegra.dept.store@gmail.com',password: 'possales', password_confirmation: 'possales', role: :sales)
end
puts 'seed user DONE'
