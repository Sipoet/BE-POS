# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or find_or_created_by alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

ApplicationRecord.transaction do
  puts 'seed roles'
  Role.find_or_create_by!(name: 'SUPERADMIN')
  Role.find_or_create_by!(name: 'SENIOR KASIR')
  Role.find_or_create_by!(name: 'SENIOR SALES')
  Role.find_or_create_by!(name: 'GUDANG')
  Role.find_or_create_by!(name: 'JUNIOR KASIR')
  Role.find_or_create_by!(name: 'EXECUTIVE')
  Role.find_or_create_by!(name: 'SALES LEADER')
  Role.find_or_create_by!(name: 'ONLINE')
  Role.find_or_create_by!(name: 'FINANCE')
  Role.find_or_create_by!(name: 'HUMAN RESOURCE')
  puts 'seed roles DONE'
  puts 'seed user superadmin'
  User.find_or_create_by!(name: 'superadmin', role: Role.find_by(name: 'SUPERADMIN'),
                          password: Rails.env['ADMIN_PASSWORD'], password_confirmation: Rails.env['ADMIN_PASSWORD'])
  puts 'seed user superadmin DONE'
  puts 'seed payment type superadmin DONE'
  %w[debit_card
     credit_card
     qris
     emoney
     tap
     transfer
     other].each do |payment_type_name|
    PaymentType.find_or_create_by!(name: payment_type_name)
  end
end
