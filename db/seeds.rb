# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# for development only
puts 'seed roles'
Role.transaction do
  Role.create!(name:'superadmin')
  Role.create!(name: 'senior_cashier')
  Role.create!(name: 'junior_cashier')
  Role.create!(name: 'warehouse')
  Role.create!(name: 'junior_sales')
  Role.create!(name: 'senior_sales')
  Role.create!(name: 'sales_manager')
  Role.create!(name: 'online')
  Role.create!(name: 'finance')
  Role.create!(name: 'human_resource')
end
puts 'seed user DONE'
