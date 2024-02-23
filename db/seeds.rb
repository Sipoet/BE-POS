# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

ApplicationRecord.transaction do
  puts 'seed roles'
  Role.create!(name: 'SUPERADMIN')
  Role.create!(name: 'SENIOR KASIR')
  Role.create!(name: 'SENIOR SALES')
  Role.create!(name: 'GUDANG')
  Role.create!(name: 'JUNIOR KASIR')
  Role.create!(name: 'EXECUTIVE')
  Role.create!(name: 'SALES LEADER')
  Role.create!(name: 'ONLINE')
  Role.create!(name: 'FINANCE')
  Role.create!(name: 'HUMAN RESOURCE')
  puts 'seed roles DONE'
  puts 'seed user superadmin'
  User.create(name: 'superadmin', role: Role.find_by(name:'SUPERADMIN'), password: Rails.env['ADMIN_PASSWORD'], password_confirmation: Rails.env['ADMIN_PASSWORD'])
  puts 'seed user superadmin DONE'
end
