# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_03_03_092132) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_authorizes", force: :cascade do |t|
    t.string "controller", null: false
    t.string "action", null: false
    t.integer "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_access_authorizes_on_role_id"
  end

  create_table "column_authorizes", force: :cascade do |t|
    t.string "table", null: false
    t.string "column", null: false
    t.integer "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_column_authorizes_on_role_id"
  end

  create_table "discounts", force: :cascade do |t|
    t.string "code", null: false
    t.string "item_code"
    t.string "supplier_code"
    t.string "brand_name"
    t.string "item_type_name"
    t.decimal "discount1", default: "0.0", null: false
    t.decimal "discount2", default: "0.0", null: false
    t.decimal "discount3", default: "0.0", null: false
    t.decimal "discount4", default: "0.0", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "weight", default: 1, null: false
    t.integer "calculation_type", default: 0, null: false
    t.string "blacklist_supplier_code"
    t.string "blacklist_item_type_name"
    t.string "blacklist_brand_name"
    t.index ["code"], name: "index_discounts_on_code", unique: true
    t.index ["start_time", "end_time", "item_code", "supplier_code", "item_type_name", "brand_name"], name: "active_promotion_idx", order: { end_time: :desc }
    t.index ["start_time", "end_time"], name: "index_discounts_on_start_time_and_end_time", order: { end_time: :desc }
  end

  create_table "employee_attendances", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.date "date", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id", "date"], name: "index_employee_attendances_on_employee_id_and_date", unique: true
  end

  create_table "employee_leaves", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.integer "leave_type", null: false
    t.date "date", null: false
    t.date "change_date"
    t.integer "change_shift"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id", "date"], name: "index_employee_leaves_on_employee_id_and_date", unique: true
  end

  create_table "employees", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.integer "role_id", null: false
    t.decimal "debt", default: "0.0", null: false
    t.date "start_working_date", null: false
    t.date "end_working_date"
    t.integer "payroll_id"
    t.integer "status", default: 0, null: false
    t.integer "shift", default: 1, null: false
    t.text "description"
    t.string "id_number"
    t.string "contact_number"
    t.string "address"
    t.string "bank"
    t.string "bank_register_name"
    t.string "bank_account"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_code"
    t.index ["code"], name: "index_employees_on_code", unique: true
  end

  create_table "file_stores", force: :cascade do |t|
    t.string "code", null: false
    t.string "filename", null: false
    t.binary "file", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expired_at"
    t.index ["code"], name: "index_file_stores_on_code", unique: true
  end

  create_table "payroll_lines", force: :cascade do |t|
    t.integer "payroll_id", null: false
    t.integer "row", null: false
    t.integer "group", null: false
    t.integer "payroll_type"
    t.integer "formula", null: false
    t.string "description", null: false
    t.decimal "variable1"
    t.decimal "variable2"
    t.decimal "variable3"
    t.decimal "variable4"
    t.decimal "variable5"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payroll_id"], name: "index_payroll_lines_on_payroll_id"
  end

  create_table "payrolls", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "paid_time_off", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payslip_lines", force: :cascade do |t|
    t.integer "payslip_id", null: false
    t.integer "group", null: false
    t.integer "payslip_type", null: false
    t.string "description", null: false
    t.decimal "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payslip_id", "payslip_type"], name: "emp_pay_line_idx"
    t.index ["payslip_id"], name: "index_payslip_lines_on_payslip_id"
  end

  create_table "payslips", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.integer "payroll_id", null: false
    t.integer "status", default: 0, null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.datetime "payment_time"
    t.decimal "gross_salary", null: false
    t.text "notes"
    t.decimal "tax_amount", default: "0.0", null: false
    t.decimal "nett_salary", null: false
    t.integer "sick_leave", default: 0, null: false
    t.integer "known_absence", default: 0, null: false
    t.integer "work_days", default: 0, null: false
    t.integer "unknown_absence", default: 0, null: false
    t.integer "paid_time_off", default: 0, null: false
    t.integer "overtime_hour", default: 0, null: false
    t.integer "late", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "key_name", null: false
    t.integer "user_id"
    t.text "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key_name"], name: "index_settings_on_key_name"
    t.index ["user_id"], name: "index_settings_on_user_id"
  end

  create_table "tbl_acc_sa", id: false, force: :cascade do |t|
    t.string "kodeacc", limit: 30, null: false
    t.date "tanggal"
    t.string "matauang", limit: 20
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd", precision: nil
    t.index ["matauang"], name: "matauang"
  end

  create_table "tbl_acc_tmplrnr", id: false, force: :cascade do |t|
    t.string "kodeacc", limit: 50
    t.integer "urut", default: 0
    t.string "tipeacc", limit: 5
    t.string "sub1", limit: 100
    t.string "sub2", limit: 100
    t.string "sub3", limit: 100
    t.string "sub4", limit: 100
    t.string "sub5", limit: 100
    t.string "sub6", limit: 100
    t.decimal "nilai", precision: 35, scale: 20
    t.integer "setsub"
    t.string "usergen", limit: 50
  end

  create_table "tbl_accdepositdt", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.integer "nobaris"
    t.string "notransaksi", limit: 50
    t.string "kodeacc", limit: 30
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.datetime "dateupd"
    t.index ["notransaksi"], name: "notransaksi_depo"
  end

  create_table "tbl_accdeposithd", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodekantor", limit: 50
    t.string "kodeacc", limit: 30
    t.string "kodeaccto", limit: 30
    t.datetime "tanggal"
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.string "tipe", limit: 30
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.text "keterangan"
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd"
    t.string "shiftkerja", limit: 20
    t.string "kodesupel", limit: 50
    t.string "tipetrs", limit: 30
    t.boolean "bc_trf_sts", default: false
    t.index ["kodeacc"], name: "kodeacc_depo"
    t.index ["kodeaccto"], name: "kodeaccto_depo"
    t.index ["kodekantor"], name: "kodekantor_depo"
    t.index ["kodesupel"], name: "kodesupel_depo"
    t.index ["matauang"], name: "matauang1_depo"
  end

  create_table "tbl_accjurnal", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.integer "nourut"
    t.string "tipeinput", limit: 5
    t.string "notransaksi", limit: 100
    t.datetime "tanggal", precision: nil
    t.string "kodeacc", limit: 30
    t.string "jenis", limit: 20
    t.text "keterangan"
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.decimal "jumlah", precision: 35, scale: 20, default: "0.0"
    t.string "posisi", limit: 5
    t.decimal "debet", precision: 35, scale: 20, default: "0.0"
    t.decimal "kredit", precision: 35, scale: 20, default: "0.0"
    t.string "kantor", limit: 50
    t.string "modul", limit: 20
    t.index ["notransaksi"], name: "tbl_accjurnal_notrs"
  end

  create_table "tbl_acckasdt", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.integer "nobaris"
    t.string "notransaksi", limit: 50
    t.string "kodeacc", limit: 30
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.datetime "dateupd", precision: nil
    t.text "keterangan"
    t.index ["notransaksi"], name: "notransaksi"
    t.unique_constraint ["iddetail"], name: "iddetail"
  end

  create_table "tbl_acckashd", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodekantor", limit: 50
    t.string "kodeacc", limit: 30
    t.string "kodeaccto", limit: 30
    t.datetime "tanggal", precision: nil
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.string "tipe", limit: 30
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.decimal "subtotal", precision: 20, scale: 3, default: "0.0"
    t.text "keterangan"
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd", precision: nil
    t.string "shiftkerja", limit: 20
    t.boolean "bc_trf_sts", default: false
    t.index ["kodeacc"], name: "kodeacc"
    t.index ["kodeaccto"], name: "kodeaccto"
    t.index ["kodekantor"], name: "kodekantor"
    t.index ["matauang"], name: "matauang1"
  end

  create_table "tbl_acctmpns", id: false, force: :cascade do |t|
    t.string "kodeacc", limit: 30
    t.string "kelompok", limit: 5
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.decimal "rdebet", precision: 20, scale: 3, default: "0.0"
    t.decimal "rkredit", precision: 20, scale: 3, default: "0.0"
    t.decimal "debet", precision: 20, scale: 3, default: "0.0"
    t.decimal "kredit", precision: 20, scale: 3, default: "0.0"
    t.decimal "pdebet", precision: 20, scale: 3, default: "0.0"
    t.decimal "pkredit", precision: 20, scale: 3, default: "0.0"
    t.decimal "tdebet", precision: 20, scale: 3, default: "0.0"
    t.decimal "tkredit", precision: 20, scale: 3, default: "0.0"
    t.decimal "lrdebet", precision: 20, scale: 3, default: "0.0"
    t.decimal "lrkredit", precision: 20, scale: 3, default: "0.0"
    t.decimal "ndebet", precision: 20, scale: 3, default: "0.0"
    t.decimal "nkredit", precision: 20, scale: 3, default: "0.0"
    t.string "usergen", limit: 50
  end

  create_table "tbl_alamatkirim", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "kode_supel", limit: 50
    t.string "kontak", limit: 150
    t.string "alamat", limit: 200
    t.string "kota", limit: 100
    t.string "telepon", limit: 200
    t.string "kotatujuan", limit: 100
    t.string "kodekantor", limit: 50
    t.string "subwilasal", limit: 100
    t.string "subwiltujuan", limit: 100
  end

  create_table "tbl_bank", primary_key: "kodebank", id: { type: :string, limit: 30 }, force: :cascade do |t|
    t.string "namabank", limit: 100
    t.string "acc_kd", limit: 30
    t.string "acc_kk", limit: 30
  end

  create_table "tbl_byrhutangdt", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "notransaksi", limit: 50
    t.string "notrsmasuk", limit: 50
    t.string "tipe", limit: 20
    t.string "matauang", limit: 50
    t.decimal "ratetrs", precision: 35, scale: 20, default: "0.0"
    t.decimal "jmlkredit", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_pot", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_total", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_byr", precision: 20, scale: 3, default: "0.0"
    t.datetime "dateupd", precision: nil
    t.index ["matauang"], name: "matauang2"
    t.index ["notransaksi"], name: "notransaksi1"
    t.index ["notrsmasuk"], name: "notrsmasuk"
  end

  create_table "tbl_byrhutanghd", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodekantor", limit: 50
    t.datetime "tanggal", precision: nil
    t.string "tipe", limit: 20
    t.string "kodesupel", limit: 50
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.decimal "totalbayar", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalpotongan", precision: 20, scale: 3
    t.string "acc_bayar", limit: 30
    t.string "acc_pot", limit: 30
    t.string "carabayar", limit: 5, default: "TN"
    t.datetime "byr_krd_jt", precision: nil
    t.string "nomor", limit: 50
    t.text "keterangan"
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd", precision: nil
    t.string "shiftkerja", limit: 20
    t.boolean "stslunas", default: false
    t.datetime "tgllunas_cbg", precision: 0
    t.boolean "bc_trf_sts", default: false
    t.index ["kodekantor"], name: "kodekantor1"
    t.index ["kodesupel"], name: "kodesupplier"
    t.index ["matauang"], name: "matauang3"
  end

  create_table "tbl_byrhutangitem", id: false, force: :cascade do |t|
    t.string "iddetail", limit: 150
    t.string "iddetailitem", limit: 150
    t.string "notransaksi", limit: 50
    t.string "kodeitem", limit: 100
    t.decimal "jmlretur", precision: 20, scale: 3
    t.decimal "jmllaku", precision: 20, scale: 3
  end

  create_table "tbl_byrhutangkonsidt", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "notransaksi", limit: 50
    t.string "notrsmasuk", limit: 50
    t.string "tipe", limit: 20
    t.string "matauang", limit: 50
    t.decimal "ratetrs", precision: 35, scale: 20, default: "0.0"
    t.decimal "jmlkredit", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_pot", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_total", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_byr", precision: 20, scale: 3, default: "0.0"
    t.datetime "dateupd"
    t.index ["matauang"], name: "matauang2_kinhd"
    t.index ["notransaksi"], name: "notransaksi1_kinhd"
    t.index ["notrsmasuk"], name: "notrsmasuk_kinhd"
  end

  create_table "tbl_byrhutangkonsihd", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodekantor", limit: 50
    t.datetime "tanggal"
    t.string "tipe", limit: 20
    t.string "kodesupel", limit: 50
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.decimal "totalbayar", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalpotongan", precision: 20, scale: 3
    t.string "acc_bayar", limit: 30
    t.string "acc_pot", limit: 30
    t.string "carabayar", limit: 5, default: "TN"
    t.datetime "byr_krd_jt"
    t.string "nomor", limit: 50
    t.text "keterangan"
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd"
    t.string "shiftkerja", limit: 20
    t.boolean "stslunas", default: false
    t.decimal "xx", precision: 20, scale: 3
    t.datetime "tgllunas_cbg", precision: 0
    t.boolean "bc_trf_sts", default: false
    t.index ["kodekantor"], name: "kodekantor1_kinhd"
    t.index ["kodesupel"], name: "kodesupplier_kinhd"
    t.index ["matauang"], name: "matauang3_kinhd"
  end

  create_table "tbl_byrkomisislsdt", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "notransaksi", limit: 50
    t.string "notrsmasuk", limit: 50
    t.string "tipe", limit: 20
    t.string "matauang", limit: 50
    t.decimal "ratetrs", precision: 35, scale: 20, default: "0.0"
    t.decimal "jmlkredit", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_pot", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_total", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_byr", precision: 20, scale: 3, default: "0.0"
    t.datetime "dateupd"
    t.string "kodesupel", limit: 50
  end

  create_table "tbl_byrkomisislshd", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodekantor", limit: 50
    t.datetime "tanggal"
    t.string "tipe", limit: 20
    t.string "kodesupel", limit: 50
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.decimal "totalbayar", precision: 20, scale: 3, default: "0.0"
    t.string "acc_bayar", limit: 30
    t.string "acc_komisi_sales", limit: 30
    t.string "carabayar", limit: 5, default: "TN"
    t.datetime "byr_krd_jt"
    t.string "nomor", limit: 50
    t.text "keterangan"
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd"
    t.string "shiftkerja", limit: 20
    t.boolean "stslunas", default: false
    t.datetime "periodetgl1"
    t.datetime "periodetgl2"
    t.datetime "tgllunas_cbg", precision: 0
    t.boolean "bc_trf_sts", default: false
  end

  create_table "tbl_byrpiutangdt", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "notransaksi", limit: 50
    t.string "notrsmasuk", limit: 50
    t.string "tipe", limit: 20
    t.string "matauang", limit: 50
    t.decimal "ratetrs", precision: 35, scale: 20, default: "0.0"
    t.decimal "jmlkredit", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_pot", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_total", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_byr", precision: 20, scale: 3, default: "0.0"
    t.datetime "dateupd", precision: nil
    t.index ["matauang"], name: "matauang4"
    t.index ["notransaksi"], name: "notransaksi2"
    t.index ["notrsmasuk"], name: "notrsmasuk1"
  end

  create_table "tbl_byrpiutanghd", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodekantor", limit: 50
    t.datetime "tanggal", precision: nil
    t.string "tipe", limit: 20
    t.string "kodesupel", limit: 50
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.decimal "totalbayar", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalpotongan", precision: 20, scale: 3
    t.string "acc_bayar", limit: 30
    t.string "acc_pot", limit: 30
    t.string "carabayar", limit: 5, default: "TN"
    t.datetime "byr_krd_jt", precision: nil
    t.string "nomor", limit: 50
    t.text "keterangan"
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd", precision: nil
    t.string "shiftkerja", limit: 20
    t.boolean "stslunas", default: false
    t.datetime "tgllunas_cbg", precision: 0
    t.boolean "bc_trf_sts", default: false
    t.index ["kodekantor"], name: "kodekantor2"
    t.index ["kodesupel"], name: "kodesupplier1"
    t.index ["matauang"], name: "matauang5"
  end

  create_table "tbl_byrpiutangkonsidt", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "notransaksi", limit: 50
    t.string "notrsmasuk", limit: 50
    t.string "tipe", limit: 5
    t.string "matauang", limit: 50
    t.decimal "ratetrs", precision: 35, scale: 20, default: "0.0"
    t.decimal "jmlkredit", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_pot", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_total", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_byr", precision: 20, scale: 3, default: "0.0"
    t.datetime "dateupd"
    t.index ["matauang"], name: "matauang4_tko"
    t.index ["notransaksi"], name: "notransaksi2_tko"
    t.index ["notrsmasuk"], name: "notrsmasuk1_tko"
  end

  create_table "tbl_byrpiutangkonsihd", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodekantor", limit: 50
    t.datetime "tanggal"
    t.string "tipe", limit: 5
    t.string "kodesupel", limit: 50
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.decimal "totalbayar", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalpotongan", precision: 20, scale: 3
    t.string "acc_bayar", limit: 30
    t.string "acc_pot", limit: 30
    t.string "carabayar", limit: 5, default: "TN"
    t.datetime "byr_krd_jt"
    t.string "nomor", limit: 50
    t.text "keterangan"
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd"
    t.string "shiftkerja", limit: 20
    t.boolean "stslunas", default: false
    t.datetime "tgllunas_cbg", precision: 0
    t.boolean "bc_trf_sts", default: false
    t.index ["kodekantor"], name: "kodekantor2_tko"
    t.index ["kodesupel"], name: "kodesupplier1_tko"
    t.index ["matauang"], name: "matauang5_tko"
  end

  create_table "tbl_conf", primary_key: "confname", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "confvalue", limit: 254
    t.binary "confblob"
  end

  create_table "tbl_emoney", primary_key: "kodeprod", id: { type: :string, limit: 30 }, force: :cascade do |t|
    t.string "namaprod", limit: 100
    t.string "acc_prod", limit: 30
  end

  create_table "tbl_formatnosp", primary_key: "trid", id: { type: :string, limit: 5 }, force: :cascade do |t|
    t.bigint "nomor"
    t.string "slot1", limit: 10
    t.string "slot2", limit: 10
    t.string "slot3", limit: 10
    t.string "sep1", limit: 2
    t.string "sep2", limit: 2
    t.integer "numdgt"
    t.string "lastnom", limit: 200
  end

  create_table "tbl_formatnotr", primary_key: ["trid", "kantor"], force: :cascade do |t|
    t.string "trid", limit: 10, null: false
    t.bigint "nomor", default: 0
    t.string "slot1", limit: 10
    t.string "slot2", limit: 10
    t.string "slot3", limit: 10
    t.string "slot4", limit: 10
    t.string "slot5", limit: 10
    t.string "sep1", limit: 2
    t.string "sep2", limit: 2
    t.string "sep3", limit: 2
    t.string "sep4", limit: 2
    t.string "resetid", limit: 10
    t.integer "numdgt", default: 0
    t.string "notransaksi", limit: 50
    t.string "kantor", limit: 50, null: false
    t.datetime "lastgen", precision: 0
  end

  create_table "tbl_hupi_sa", id: false, force: :cascade do |t|
    t.string "kodesupel", limit: 50
    t.datetime "tanggal", precision: nil
    t.string "kode_acc", limit: 30
    t.string "kodemu", limit: 50
    t.decimal "jumlah", precision: 20, scale: 3
    t.string "tipe", limit: 20
    t.string "tipetrs", limit: 20
  end

  create_table "tbl_ikdt", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.integer "nobaris", default: 0
    t.string "notransaksi", limit: 50
    t.string "kodeitem", limit: 100
    t.decimal "jumlah", precision: 35, scale: 20, default: "0.0"
    t.decimal "jmlpesan", precision: 35, scale: 20, default: "0.0"
    t.string "satuan", limit: 50
    t.decimal "harga", precision: 35, scale: 20, default: "0.0"
    t.decimal "potongan", precision: 35, scale: 20, default: "0.0"
    t.decimal "potongan2", precision: 35, scale: 20, default: "0.0"
    t.decimal "potongan3", precision: 35, scale: 20, default: "0.0"
    t.decimal "potongan4", precision: 35, scale: 20, default: "0.0"
    t.decimal "total", precision: 20, scale: 3, default: "0.0"
    t.decimal "pajak", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlrmasuk", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkeluar", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlrkeluar", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlsisa", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkonsibayar", precision: 20, scale: 3, default: "0.0"
    t.string "idorder", limit: 150
    t.datetime "dateupd", precision: nil
    t.string "idtrsretur", limit: 150
    t.decimal "jmlretur", precision: 20, scale: 3, default: "0.0"
    t.text "detinfo"
    t.string "notrsretur", limit: 100
    t.decimal "potpiutang", precision: 50, scale: 3
    t.decimal "jmlkonversi", precision: 50, scale: 3, default: "0.0"
    t.decimal "jmlterimajadi", precision: 20, scale: 3, default: "0.0"
    t.string "sistemhargajual", limit: 1
    t.string "tipepromo", limit: 15, default: "N"
    t.decimal "jmlgratis", precision: 20, scale: 3, default: "0.0"
    t.string "itempromo", limit: 100
    t.string "satuanpromo", limit: 50
    t.decimal "hppdasar", precision: 35, scale: 20, default: "0.0"
    t.boolean "tebus", default: false
    t.datetime "tglexp"
    t.string "kodeprod", limit: 100
    t.index ["kodeitem"], name: "kodeitem1"
    t.index ["notransaksi"], name: "tbl_ikdt_ikhd"
  end

  create_table "tbl_ikhd", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodekantor", limit: 50
    t.string "kantordari", limit: 50
    t.datetime "tanggal", precision: nil
    t.string "tipe", limit: 20
    t.string "notrsorder", limit: 50
    t.string "kodesupel", limit: 50
    t.string "kodesales", limit: 50
    t.string "kodesales2", limit: 50
    t.string "kodesales3", limit: 50
    t.string "kodesales4", limit: 50
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.text "keterangan"
    t.decimal "totalitem", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalitempesan", precision: 20, scale: 3, default: "0.0"
    t.decimal "subtotal", precision: 20, scale: 3, default: "0.0"
    t.decimal "potfaktur", precision: 25, scale: 10, default: "0.0"
    t.decimal "pajak", precision: 20, scale: 3, default: "0.0"
    t.decimal "biayalain", precision: 20, scale: 3, default: "0.0"
    t.decimal "dppesanan", precision: 20, scale: 3, default: "0.0"
    t.decimal "prpajak", precision: 10, scale: 3, default: "0.0"
    t.decimal "totalakhir", precision: 20, scale: 3, default: "0.0"
    t.string "carabayar", limit: 20
    t.decimal "jmltunai", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkredit", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmldebit", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkk", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi1", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi2", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi3", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi4", precision: 20, scale: 3, default: "0.0"
    t.string "notrsretur", limit: 100
    t.string "ppn", limit: 30
    t.decimal "totalkotagih", precision: 20, scale: 3, default: "0.0"
    t.string "acc_potongan", limit: 30, comment: "POTONGAN"
    t.string "acc_pajak", limit: 30, comment: "PAJAK"
    t.string "acc_biayalain", limit: 30, comment: "BIAYA"
    t.string "acc_tunai", limit: 30, comment: "BAYAR TUNAI"
    t.string "acc_kredit", limit: 30, comment: "BAYAR KREDIT"
    t.string "acc_sales", limit: 30, comment: "SALES"
    t.string "acc_hpp", limit: 30
    t.string "acc_debit", limit: 30
    t.string "acc_kk", limit: 30
    t.string "acc_deposit", limit: 30, comment: "BAYAR DEPOSIT"
    t.string "acc_sales_hut", limit: 30, comment: "HUTANG SALES"
    t.string "acc_biaya_pot", limit: 30
    t.string "acc_dppesanan", limit: 30
    t.string "acc_beda_cab", limit: 30
    t.datetime "byr_krd_jt", precision: nil
    t.string "byr_krd_no", limit: 30
    t.string "byr_debit_bank", limit: 30
    t.string "byr_kk_bank", limit: 30
    t.string "byr_debit_no", limit: 100
    t.string "byr_kk_no", limit: 100
    t.decimal "krd_jml_pot", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_byr", precision: 20, scale: 3, default: "0.0"
    t.decimal "potnomfaktur", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmldeposit", precision: 20, scale: 3, default: "0.0"
    t.decimal "point_ik", precision: 20, scale: 3, default: "0.0"
    t.integer "point_sts", default: 0
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd", precision: nil
    t.date "tanggal_sa"
    t.boolean "biaya_msk_total"
    t.string "compname", limit: 255
    t.string "shiftkerja", limit: 20
    t.string "nofp", limit: 100
    t.boolean "byr_komisi1"
    t.boolean "byr_komisi2"
    t.boolean "byr_komisi3"
    t.boolean "byr_komisi4"
    t.string "point_notrans", limit: 50
    t.decimal "totalterimajadi", precision: 20, scale: 3, default: "0.0"
    t.string "ak_kotatujuan", limit: 100
    t.string "opsikirim", limit: 5, default: "1"
    t.boolean "bc_trf_sts", default: false
    t.string "ambilnomor", limit: 50
    t.decimal "jumlah_cetak", precision: 5, scale: 3, default: "0.0"
    t.boolean "status_online", default: false
    t.string "compname_online", limit: 255
    t.string "user_online", limit: 50
    t.string "mode_retur", limit: 5
    t.decimal "jmlemoney", precision: 20, scale: 3, default: "0.0"
    t.string "byr_emoney_no", limit: 100
    t.string "byr_emoney_prod", limit: 30
    t.string "acc_emoney", limit: 30
    t.decimal "selisihpembulatan", precision: 20, scale: 3, default: "0.0"
    t.string "acc_pend_pembulatan", limit: 30
    t.string "kodevoucher", limit: 50
    t.string "opsikembalian", limit: 5
    t.decimal "jmlopkembali", precision: 20, scale: 3
    t.string "acc_donasi", limit: 30
    t.decimal "krd_jml_byr_ls", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_pot_ls", precision: 20, scale: 3, default: "0.0"
    t.index ["kantordari"], name: "kantordari"
    t.index ["kodekantor"], name: "kodekantor3"
    t.index ["kodesales"], name: "kodesales"
    t.index ["kodesales2"], name: "kodesales2"
    t.index ["kodesales3"], name: "kodesales3"
    t.index ["kodesupel"], name: "kodesupel1"
    t.index ["matauang"], name: "matauang6"
  end

  create_table "tbl_ikrakitan", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "iddetailtrs", limit: 150
    t.string "notransaksi", limit: 50
    t.string "tipe", limit: 20
    t.string "kodeitem", limit: 100
    t.string "kodeitemrakitan", limit: 100
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.string "satuan", limit: 50
    t.decimal "harga", precision: 20, scale: 3, default: "0.0"
    t.decimal "total", precision: 20, scale: 3, default: "0.0"
    t.decimal "jumlahtrs", precision: 20, scale: 3, default: "0.0"
    t.string "satuantrs", limit: 50
    t.datetime "dateupd", precision: nil
    t.string "jenisrakit", limit: 20
    t.decimal "totalhppitem", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkonversi", precision: 50, scale: 3, default: "0.0"
    t.decimal "hppdasar", precision: 35, scale: 20, default: "0.0"
    t.index ["iddetailtrs"], name: "tbl_ikrakitan_detailtrs1"
    t.index ["kodeitem"], name: "kodeitem2"
    t.index ["kodeitemrakitan"], name: "kodeitemrakitan"
    t.index ["notransaksi"], name: "notransaksi3"
  end

  create_table "tbl_imdt", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.integer "nobaris", default: 0
    t.string "notransaksi", limit: 50
    t.string "kodeitem", limit: 100
    t.decimal "jumlah", precision: 35, scale: 20, default: "0.0"
    t.decimal "jmlpesan", precision: 35, scale: 20, default: "0.0"
    t.string "satuan", limit: 50
    t.decimal "harga", precision: 35, scale: 20, default: "0.0"
    t.decimal "potongan", precision: 35, scale: 20, default: "0.0"
    t.decimal "total", precision: 20, scale: 3, default: "0.0"
    t.decimal "pajak", precision: 20, scale: 3, default: "0.0"
    t.decimal "hargadsr", precision: 20, scale: 3, default: "0.0"
    t.string "satuandsr", limit: 50
    t.decimal "jmlmasuk", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlrmasuk", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkeluar", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlrkeluar", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlsisa", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkonsibayar", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlretur", precision: 20, scale: 3, default: "0.0"
    t.datetime "tglexp", precision: nil
    t.string "idtrsretur", limit: 150
    t.string "kodeprod", limit: 100
    t.string "idorder", limit: 150
    t.datetime "dateupd", precision: nil
    t.string "sakantor", limit: 50
    t.text "detinfo"
    t.decimal "pothutang", precision: 50, scale: 3
    t.string "notrsretur", limit: 100
    t.decimal "jmlkonversi", precision: 50, scale: 3, default: "0.0"
    t.decimal "jmlprosesrakit", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmltagihki", precision: 20, scale: 3, default: "0.0"
    t.decimal "potongan2", precision: 35, scale: 20, default: "0.0"
    t.decimal "potongan3", precision: 35, scale: 20, default: "0.0"
    t.decimal "potongan4", precision: 35, scale: 20, default: "0.0"
    t.decimal "hppdasar", precision: 35, scale: 20, default: "0.0"
    t.index ["iddetail"], name: "iddetail1"
    t.index ["kodeitem"], name: "kodeitem3"
    t.index ["notransaksi"], name: "tbl_belidt_belihd1"
  end

  create_table "tbl_imhd", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodekantor", limit: 50
    t.string "kantortujuan", limit: 50
    t.datetime "tanggal", precision: nil
    t.string "tipe", limit: 20
    t.string "notrsorder", limit: 50
    t.string "kodesupel", limit: 50
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.text "keterangan"
    t.decimal "totalitem", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalitempesan", precision: 20, scale: 3, default: "0.0"
    t.decimal "subtotal", precision: 20, scale: 3, default: "0.0"
    t.decimal "potfaktur", precision: 25, scale: 10, default: "0.0"
    t.decimal "pajak", precision: 20, scale: 3, default: "0.0"
    t.decimal "biayalain", precision: 20, scale: 3, default: "0.0"
    t.decimal "prpajak", precision: 10, scale: 3, default: "0.0"
    t.decimal "dppesanan", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmldeposit", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalakhir", precision: 20, scale: 3, default: "0.0"
    t.string "carabayar", limit: 20
    t.decimal "jmltunai", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkredit", precision: 20, scale: 3, default: "0.0"
    t.decimal "potnomfaktur", precision: 20, scale: 3, default: "0.0"
    t.datetime "byr_krd_jt", precision: nil
    t.string "byr_krd_no", limit: 30
    t.decimal "krd_jml_pot", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_byr", precision: 20, scale: 3, default: "0.0"
    t.string "ppn", limit: 30
    t.string "notrsretur", limit: 100
    t.string "acc_potongan", limit: 30, comment: "POTONGAN"
    t.string "acc_pajak", limit: 30, comment: "PAJAK"
    t.string "acc_biayalain", limit: 30, comment: "BIAYA"
    t.string "acc_tunai", limit: 30
    t.string "acc_kredit", limit: 30
    t.string "acc_hpp", limit: 30
    t.string "acc_deposit", limit: 30
    t.string "acc_dppesanan", limit: 30
    t.string "acc_biaya_pot", limit: 30
    t.string "acc_beda_cab", limit: 30
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd", precision: nil
    t.boolean "biaya_msk_total"
    t.string "compname", limit: 255
    t.string "shiftkerja", limit: 20
    t.date "tanggal_sa"
    t.boolean "bc_trf_sts", default: false
    t.decimal "tottagihki", precision: 20, scale: 3, default: "0.0"
    t.decimal "totitemretur", precision: 20, scale: 3, default: "0.0"
    t.boolean "swt_sa_sts", default: false
    t.decimal "prpotfaktur", precision: 25, scale: 10
    t.string "nofp", limit: 100
    t.boolean "status_online", default: false
    t.string "compname_online", limit: 255
    t.string "user_online", limit: 50
    t.string "mode_retur", limit: 5
    t.index ["kantortujuan"], name: "kantortujuan"
    t.index ["kodekantor"], name: "kodekantor4"
    t.index ["kodesupel"], name: "kodesupplier2"
    t.index ["matauang"], name: "matauang7"
  end

  create_table "tbl_imrakitan", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "iddetailtrs", limit: 150
    t.string "notransaksi", limit: 50
    t.string "tipe", limit: 20
    t.string "kodeitem", limit: 100
    t.string "kodeitemrakitan", limit: 100
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.string "satuan", limit: 50
    t.decimal "harga", precision: 20, scale: 3, default: "0.0"
    t.decimal "total", precision: 20, scale: 3, default: "0.0"
    t.decimal "jumlahtrs", precision: 20, scale: 3, default: "0.0"
    t.string "satuantrs", limit: 50
    t.datetime "dateupd", precision: nil
    t.decimal "jmlkonversi", precision: 50, scale: 3, default: "0.0"
    t.index ["iddetailtrs"], name: "tbl_ikrakitan_detailtrs2"
    t.index ["kodeitem"], name: "kodeitem4"
    t.index ["kodeitemrakitan"], name: "kodeitemrakitan1"
    t.index ["notransaksi"], name: "notransaksi4"
  end

  create_table "tbl_infodb", id: false, force: :cascade do |t|
    t.string "versidb", limit: 255
    t.string "versiupdate", limit: 20
  end

  create_table "tbl_item", primary_key: "kodeitem", id: { type: :string, limit: 100 }, force: :cascade do |t|
    t.text "namaitem"
    t.string "jenis", limit: 50
    t.string "tipe", limit: 15, default: "Y"
    t.string "matauang", limit: 50
    t.string "serial", limit: 15, default: "N"
    t.string "konsinyasi", limit: 15, default: "N"
    t.decimal "stokmin", precision: 20, scale: 3, default: "0.0"
    t.string "sistemhargajual", limit: 1, default: "J"
    t.boolean "opsihargajual", default: true
    t.string "rak", limit: 100
    t.string "satuan", limit: 50
    t.decimal "hargapokok", precision: 35, scale: 20, default: "0.0"
    t.decimal "prhargajual1", precision: 20, scale: 3, default: "0.0"
    t.decimal "hargajual1", precision: 20, scale: 3, default: "0.0"
    t.text "keterangan"
    t.string "supplier1", limit: 50
    t.string "supplier2", limit: 50
    t.string "supplier3", limit: 50
    t.binary "gambar"
    t.string "statusjual", limit: 15
    t.string "merek", limit: 50
    t.string "hppsys", limit: 10
    t.decimal "sistempajak", default: "0.0"
    t.boolean "opsiflexhargajual", default: false
    t.decimal "hargarakit", precision: 20, scale: 3, default: "0.0"
    t.string "statushapus", limit: 15
    t.decimal "stok", precision: 20, scale: 3, default: "0.0"
    t.string "dept", limit: 50
    t.string "pendingin", limit: 15, default: "N"
    t.string "acc_hpp", limit: 30
    t.string "acc_pendapatan", limit: 30
    t.string "acc_persediaan", limit: 30
    t.string "acc_jasa", limit: 30
    t.string "acc_noninventory", limit: 30
    t.string "acc_perbahanbaku", limit: 30
    t.string "acc_bytenagakerja", limit: 30
    t.string "acc_byoverhead", limit: 30
    t.datetime "dateupd", precision: nil
    t.decimal "tmphp", precision: 20, scale: 3, default: "0.0"
    t.decimal "tmpjml", precision: 20, scale: 3, default: "0.0"
    t.decimal "tmpnilai", precision: 20, scale: 3, default: "0.0"
    t.text "gambarfiles"
    t.datetime "tanggal_add", precision: nil
    t.boolean "opsihargarakitan", default: false
    t.boolean "nonpajakex", default: false
    t.boolean "opsidefhargapokok", default: false
    t.index ["jenis"], name: "jenis"
    t.index ["matauang"], name: "matauang8"
    t.index ["satuan"], name: "satuan"
    t.unique_constraint ["kodeitem"], name: "kodeitem"
  end

  create_table "tbl_item_ik", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "iddetailim", limit: 150, null: false
    t.string "iddetailtrs", limit: 150
    t.string "notransaksi", limit: 100
    t.string "kodekantor", limit: 50
    t.datetime "tanggal", precision: nil
    t.string "tipe", limit: 20
    t.string "kodeitem", limit: 100
    t.decimal "jumlahdasar", precision: 20, scale: 3, default: "0.0"
    t.string "satuandasar", limit: 50
    t.decimal "hargadasar", precision: 35, scale: 20, default: "0.0"
    t.decimal "jmlretur", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkotagih", precision: 20, scale: 3, default: "0.0"
    t.string "iddetailserial", limit: 150
    t.string "origin_tipe", limit: 20
    t.string "origin_iddt", limit: 150
    t.string "ori_iddetail", limit: 150
    t.string "ori_tipe", limit: 20
    t.string "noserial", limit: 255
    t.index ["iddetailim"], name: "tbl_item_ik_iddetailim"
    t.index ["iddetailtrs"], name: "tbl_item_ik_iddetailtrs"
    t.index ["notransaksi"], name: "tbl_item_ik_notrs"
    t.check_constraint "notransaksi::text <> NULL::text OR notransaksi::text <> ''::text", name: "tbl_item_ik_chk_notrsnull"
  end

  create_table "tbl_item_ikko", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "iddetailik", limit: 150
    t.string "iddetailtrs", limit: 150
    t.string "notransaksi", limit: 100
    t.string "kodeitem", limit: 100
    t.decimal "jumlahdasar", precision: 35, scale: 20, default: "0.0"
    t.decimal "hargadasar", precision: 35, scale: 20, default: "0.0"
    t.string "iddetailserial", limit: 150
    t.index ["notransaksi", "iddetailtrs", "iddetailik"], name: "tbl_item_ikko_iddetail"
  end

  create_table "tbl_item_ikret", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "iddetailik", limit: 150
    t.string "iddetailtrs", limit: 150
    t.string "notransaksi", limit: 100
    t.string "kodeitem", limit: 100
    t.decimal "jumlahdasar", precision: 20, scale: 3, default: "0.0"
    t.decimal "hargadasar", precision: 35, scale: 20, default: "0.0"
    t.string "origin_tipe", limit: 20
    t.string "origin_iddt", limit: 150
    t.string "ori_iddetail", limit: 150
    t.string "ori_tipe", limit: 20
  end

  create_table "tbl_item_im", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "iddetailtrs", limit: 150
    t.string "notransaksi", limit: 100
    t.string "kodekantor", limit: 50
    t.datetime "tanggal", precision: nil
    t.datetime "tgl_trs", precision: nil
    t.string "tipe", limit: 20
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.string "kodeitem", limit: 100
    t.decimal "jumlahdasar", precision: 20, scale: 3, default: "0.0"
    t.string "satuandasar", limit: 50
    t.decimal "hargadasar", precision: 35, scale: 20, default: "0.0"
    t.decimal "masuk", precision: 20, scale: 3, default: "0.0"
    t.decimal "keluar", precision: 20, scale: 3, default: "0.0"
    t.decimal "remasuk", precision: 20, scale: 3, default: "0.0"
    t.decimal "rekeluar", precision: 20, scale: 3, default: "0.0"
    t.decimal "transfer", precision: 20, scale: 3, default: "0.0"
    t.decimal "sisa", precision: 20, scale: 3, default: "0.0"
    t.decimal "keluar_konsi", precision: 20, scale: 3, default: "0.0"
    t.decimal "rekeluar_konsi", precision: 20, scale: 3, default: "0.0"
    t.decimal "remasuk_konsi", precision: 20, scale: 3, default: "0.0"
    t.decimal "sisa_konsi", precision: 20, scale: 3, default: "0.0"
    t.integer "flagavg", limit: 2, default: -> { "(0)::smallint" }
    t.string "origin_iddt", limit: 150
    t.string "origin_tipe", limit: 20
    t.string "ori_iddetail", limit: 150
    t.string "ori_tipe", limit: 20
    t.string "ori_id_trf", limit: 150
    t.index ["iddetailtrs"], name: "tbl_item_im_iddetailtrs"
    t.index ["notransaksi"], name: "tbl_item_im_notrs"
    t.check_constraint "notransaksi::text <> NULL::text AND notransaksi::text <> ''::text", name: "tbl_item_im_chk_notrs_null"
  end

  create_table "tbl_item_imret", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "iddetailim", limit: 150
    t.string "iddetailtrs", limit: 150
    t.string "notransaksi", limit: 100
    t.string "kodeitem", limit: 100
    t.decimal "jumlahdasar", precision: 20, scale: 3, default: "0.0"
    t.decimal "hargadasar", precision: 35, scale: 20, default: "0.0"
    t.string "idtrsserial", limit: 150
    t.string "ori_iddetail", limit: 150
    t.string "ori_tipe", limit: 20
  end

  create_table "tbl_item_rekap", id: false, force: :cascade do |t|
    t.string "kodeitem", limit: 100
    t.string "kodekantor", limit: 50
    t.integer "bulan"
    t.integer "tahun"
    t.string "satuan", limit: 50
    t.decimal "awal", precision: 20, scale: 3, default: "0.0"
    t.decimal "awal_nilai", precision: 20, scale: 3, default: "0.0"
    t.decimal "awal_total", precision: 20, scale: 3, default: "0.0"
    t.decimal "masuk", precision: 20, scale: 3, default: "0.0"
    t.decimal "masuk_nilai", precision: 20, scale: 3, default: "0.0"
    t.decimal "masuk_total", precision: 20, scale: 3, default: "0.0"
    t.decimal "keluar", precision: 20, scale: 3, default: "0.0"
    t.decimal "keluar_nilai", precision: 20, scale: 3, default: "0.0"
    t.decimal "keluar_total", precision: 20, scale: 3, default: "0.0"
    t.decimal "akhir", precision: 20, scale: 3, default: "0.0"
    t.decimal "akhir_nilai", precision: 20, scale: 3, default: "0.0"
    t.decimal "akhir_total", precision: 20, scale: 3, default: "0.0"
    t.index ["kodeitem"], name: "kodeitem5"
    t.index ["kodekantor"], name: "kodekantor5"
  end

  create_table "tbl_item_sa", primary_key: "iddetailtrs", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "notransaksi", limit: 100
    t.string "tipe", limit: 20
    t.string "kodeitem", limit: 100
    t.datetime "tanggal", precision: nil
    t.datetime "tgl_trs", precision: nil
    t.integer "nobaris", default: 0
    t.string "kodekantor", limit: 50
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.string "satuan", limit: 50
    t.decimal "harga", precision: 35, scale: 20, default: "0.0"
    t.decimal "total", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkonversi", precision: 20, scale: 3, default: "0.0"
    t.decimal "hppdasar", precision: 35, scale: 20, default: "0.0"
    t.decimal "jmlretur", precision: 35, scale: 20, default: "0.0"
    t.index ["kodeitem"], name: "kodeitem6"
    t.index ["kodekantor"], name: "kodekantor6"
    t.index ["satuan"], name: "satuan1"
  end

  create_table "tbl_itemdisp", primary_key: "iddiskon", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodeitemd", limit: 100
    t.string "kodeitems", limit: 100
    t.string "jenis", limit: 50
    t.string "merek", limit: 50
    t.datetime "tgldari"
    t.datetime "tglsampai"
    t.decimal "pot1", precision: 20, scale: 3, default: "0.0"
    t.decimal "pot2", precision: 20, scale: 3, default: "0.0"
    t.decimal "pot3", precision: 20, scale: 3, default: "0.0"
    t.decimal "pot4", precision: 20, scale: 3, default: "0.0"
    t.boolean "stsact", default: false
    t.string "tipeper", limit: 10
    t.datetime "jamdari", precision: nil
    t.datetime "jamsampai", precision: nil
    t.boolean "w1", default: false
    t.boolean "w2", default: false
    t.boolean "w3", default: false
    t.boolean "w4", default: false
    t.boolean "w5", default: false
    t.boolean "w6", default: false
    t.boolean "w7", default: false
    t.decimal "prioritas", precision: 10, default: "0"
    t.boolean "stsvcr", default: false
  end

  create_table "tbl_itemdispdt", id: false, force: :cascade do |t|
    t.string "kodeitem", limit: 100
    t.string "satuan", limit: 50
    t.integer "opsidiskon"
    t.decimal "diskon1", precision: 20, scale: 3
    t.decimal "diskon2", precision: 20, scale: 3
    t.decimal "diskon3", precision: 20, scale: 3
    t.decimal "diskon4", precision: 20, scale: 3
    t.decimal "disknom1", precision: 40, scale: 20
    t.decimal "disknom2", precision: 40, scale: 20
    t.decimal "disknom3", precision: 40, scale: 20
    t.decimal "disknom4", precision: 40, scale: 20
    t.string "iddiskon", limit: 50
    t.string "kgruppel", limit: 20
    t.index ["kodeitem", "iddiskon"], name: "index_tbl_itemdispdt_on_kodeitem_and_iddiskon", unique: true
  end

  create_table "tbl_itemhj", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "kodeitem", limit: 100
    t.string "tipehj", limit: 10
    t.decimal "jmlsampai", precision: 20, scale: 3, default: "0.0"
    t.integer "level", default: 0
    t.decimal "prosentase", precision: 20, scale: 3, default: "0.0"
    t.string "satuan", limit: 50
    t.decimal "hargajual", precision: 35, scale: 20, default: "0.0"
    t.datetime "dateupd", precision: nil
    t.index ["kodeitem"], name: "kodeitem7"
  end

  create_table "tbl_itemjenis", primary_key: "jenis", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "ketjenis", limit: 100
  end

  create_table "tbl_itemketerangan", primary_key: ["kodeket", "jenisket"], force: :cascade do |t|
    t.string "kodeket", limit: 50, null: false
    t.string "keterangan", limit: 300
    t.string "jenisket", limit: 50, null: false
  end

  create_table "tbl_itemmerek", primary_key: "merek", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "ketmerek", limit: 100
  end

  create_table "tbl_itemopname", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "periode", limit: 20
    t.datetime "tanggal", precision: nil
    t.string "kodeitem", limit: 100, null: false
    t.string "kodekantor", limit: 50
    t.string "satuan", limit: 50
    t.decimal "jmlsebelum", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlfisik", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlselisih", precision: 20, scale: 3, default: "0.0"
    t.string "kodeacc", limit: 30
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd", precision: nil
    t.decimal "harga", precision: 35, scale: 20, default: "0.0"
    t.decimal "total", precision: 20, scale: 3, default: "0.0"
    t.string "compname", limit: 255
    t.decimal "jmlkonversi", precision: 20, scale: 3, default: "0.0"
    t.decimal "hppdasar", precision: 35, scale: 20, default: "0.0"
    t.boolean "bc_trf_sts", default: false
    t.text "keterangan"
    t.index ["kodeacc"], name: "kodeacc1"
    t.index ["kodeitem"], name: "kodeitem8"
    t.index ["kodekantor"], name: "kodekantor7"
    t.index ["satuan"], name: "satuan2"
    t.unique_constraint ["iddetail"], name: "tbl_itemopname_iddetail_key"
  end

  create_table "tbl_itempotongan", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "kodeitem", limit: 100
    t.string "kodegrup", limit: 50
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.decimal "pot1", precision: 20, scale: 3, default: "0.0"
    t.decimal "pot2", precision: 20, scale: 3, default: "0.0"
    t.decimal "pot3", precision: 20, scale: 3, default: "0.0"
    t.decimal "pot4", precision: 20, scale: 3, default: "0.0"
    t.datetime "dateupd", precision: nil
  end

  create_table "tbl_itempromo", primary_key: "idpromo", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodeitemd", limit: 100
    t.string "kodeitems", limit: 100
    t.string "jenis", limit: 50
    t.string "merek", limit: 50
    t.datetime "tgldari", precision: nil
    t.datetime "tglsampai", precision: nil
    t.boolean "stsact", default: false
    t.string "tipeper", limit: 10
    t.datetime "jamdari", precision: nil
    t.datetime "jamsampai", precision: nil
    t.boolean "w1", default: false
    t.boolean "w2", default: false
    t.boolean "w3", default: false
    t.boolean "w4", default: false
    t.boolean "w5", default: false
    t.boolean "w6", default: false
    t.boolean "w7", default: false
    t.decimal "prioritas", precision: 10, default: "0"
  end

  create_table "tbl_itempromodt", id: false, force: :cascade do |t|
    t.string "kodeitem", limit: 100
    t.decimal "jumlahjual", precision: 20, scale: 3
    t.string "satuanjual", limit: 50
    t.decimal "jumlahgratis", precision: 20, scale: 3
    t.string "satuangratis", limit: 50
    t.string "idpromo", limit: 50
    t.string "kodeitemgr", limit: 100
    t.boolean "kelipatan", default: true
    t.boolean "tebus", default: false
    t.decimal "harga", precision: 20, scale: 3, default: "0.0"
    t.string "opsigratis", limit: 50, default: "1"
  end

  create_table "tbl_itemrakitan", primary_key: "iddetail", id: { type: :string, limit: 100 }, force: :cascade do |t|
    t.string "kodeitem", limit: 100
    t.string "kodeitemrakitan", limit: 100
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.string "satuan", limit: 50
    t.decimal "harga", precision: 20, scale: 3, default: "0.0"
    t.decimal "total", precision: 20, scale: 3, default: "0.0"
    t.datetime "dateupd", precision: nil
    t.string "jenis", limit: 20
    t.index ["kodeitem", "kodeitemrakitan"], name: "kodeitem9"
    t.index ["kodeitem"], name: "kodeitem_2"
    t.index ["kodeitemrakitan"], name: "kodeitemrakitan2"
  end

  create_table "tbl_itemsatuan", primary_key: "satuan", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "ketsatuan", limit: 100
    t.decimal "konversi", precision: 20, scale: 3, default: "0.0"
    t.string "satuankonversi", limit: 50
    t.boolean "utama", default: false
    t.index ["satuankonversi"], name: "satuankonversi"
  end

  create_table "tbl_itemsatuanjml", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "kodeitem", limit: 100
    t.string "satuan", limit: 30
    t.decimal "jumlahkonv", precision: 20, scale: 3, default: "0.0"
    t.string "kodebarcode", limit: 100
    t.decimal "hargapokok", precision: 35, scale: 20, default: "0.0"
    t.string "tipe", limit: 20
    t.datetime "dateupd", precision: nil
    t.decimal "poin", precision: 10
    t.decimal "komisisales", precision: 20
    t.index ["kodeitem"], name: "kodeitem10"
    t.index ["satuan"], name: "satuan3"
    t.unique_constraint ["kodebarcode"], name: "kodebarcode"
  end

  create_table "tbl_itemserial", primary_key: "noserial", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "kodeitem", limit: 100
    t.datetime "dateupd", precision: nil
    t.string "kodekantor", limit: 50
    t.string "tipe", limit: 20
    t.string "notransaksi", limit: 50
    t.string "iddetail", limit: 150
    t.decimal "harga", precision: 35, scale: 20, default: "0.0"
    t.string "origin_tipe", limit: 20
    t.string "origin_iddt", limit: 150
    t.index ["kodeitem", "kodekantor", "tipe", "notransaksi"], name: "tbl_itemserial_index"
  end

  create_table "tbl_itemserial_kotag", primary_key: "noserial", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "kodeitem", limit: 100
    t.datetime "dateupd"
    t.string "kodekantor", limit: 50
    t.string "tipe", limit: 20
    t.string "notransaksi", limit: 50
    t.string "iddetail", limit: 150
    t.decimal "harga", precision: 20, scale: 3, default: "0.0"
    t.string "iddetailtrs", limit: 150
    t.string "notrskonsinyasi", limit: 50
  end

  create_table "tbl_itemserialdt", id: false, force: :cascade do |t|
    t.string "noserial", limit: 255
    t.string "tipe", limit: 20
    t.string "notransaksi", limit: 50
    t.string "iddetail", limit: 150
    t.string "kodeitem", limit: 100
    t.string "kodekantor", limit: 50
    t.datetime "dateupd", precision: nil
    t.decimal "harga", precision: 35, scale: 20, default: "0.0"
    t.string "serialtipe", limit: 20
    t.string "serialiddetail", limit: 150
    t.string "iddetailrakitan", limit: 150
    t.string "idtrsretur", limit: 150
    t.string "statuskotag", limit: 15, default: "N"
    t.string "origin_tipe", limit: 20
    t.string "origin_iddt", limit: 150
    t.index ["iddetail", "notransaksi", "tipe"], name: "tbl_itemserialdt_index"
    t.index ["noserial"], name: "noserial"
  end

  create_table "tbl_itemserialmanage", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "periode", limit: 20
    t.datetime "tanggal"
    t.string "kodeitem", limit: 100, null: false
    t.string "kodekantor", limit: 50
    t.string "satuan", limit: 50
    t.decimal "jmlsebelum", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlfisik", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlselisih", precision: 20, scale: 3, default: "0.0"
    t.string "kodeacc", limit: 30
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd"
    t.decimal "harga", precision: 20, scale: 3, default: "0.0"
    t.decimal "total", precision: 20, scale: 3, default: "0.0"
    t.string "compname", limit: 255
    t.decimal "jmlserial", precision: 20, scale: 3, default: "0.0"
    t.index ["kodeitem"], name: "kodeitem8sm"
    t.index ["kodekantor"], name: "kodekantor7sm"
    t.index ["satuan"], name: "satuan2sm"
  end

  create_table "tbl_itemstok", id: false, force: :cascade do |t|
    t.string "kodeitem", limit: 100
    t.string "kantor", limit: 50
    t.decimal "stok", precision: 20, scale: 3
    t.decimal "hppdasar", precision: 35, scale: 20, default: "0.0"
  end

  create_table "tbl_itktdt", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.integer "nobaris", default: 0
    t.string "notransaksi", limit: 50
    t.string "kodeitem", limit: 100
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlpesan", precision: 20, scale: 3, default: "0.0"
    t.string "satuan", limit: 50
    t.decimal "harga", precision: 20, scale: 3, default: "0.0"
    t.decimal "potongan", precision: 35, scale: 20, default: "0.0"
    t.decimal "potongan2", precision: 35, scale: 20, default: "0.0"
    t.decimal "potongan3", precision: 35, scale: 20, default: "0.0"
    t.decimal "potongan4", precision: 35, scale: 20, default: "0.0"
    t.decimal "total", precision: 20, scale: 3, default: "0.0"
    t.decimal "pajak", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlrmasuk", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkeluar", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlrkeluar", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlsisa", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkonsibayar", precision: 20, scale: 3, default: "0.0"
    t.string "idorder", limit: 150
    t.datetime "dateupd"
    t.string "idtrsretur", limit: 150
    t.decimal "jmlretur", precision: 20, scale: 3, default: "0.0"
    t.text "detinfo"
    t.string "notrsretur", limit: 100
    t.decimal "potpiutang", precision: 50, scale: 3
    t.decimal "jmlkonversi", precision: 50, scale: 3, default: "0.0"
    t.decimal "jmlterimajadi", precision: 20, scale: 3, default: "0.0"
    t.string "jenis", limit: 20
    t.string "sistemhargajual", limit: 1
    t.decimal "hppdasar", precision: 35, scale: 20, default: "0.0"
    t.datetime "tglexp"
    t.string "kodeprod", limit: 100
    t.index ["kodeitem"], name: "kodeitem1tkt"
    t.index ["notransaksi"], name: "tbl_itktdt_itkthdtkt"
  end

  create_table "tbl_itkthd", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodekantor", limit: 50
    t.string "kantordari", limit: 50
    t.datetime "tanggal"
    t.string "tipe", limit: 20
    t.string "notrsorder", limit: 50
    t.string "kodesupel", limit: 50
    t.string "kodesales", limit: 50
    t.string "kodesales2", limit: 50
    t.string "kodesales3", limit: 50
    t.string "kodesales4", limit: 50
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.text "keterangan"
    t.decimal "totalitemin", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalitemout", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalitempesan", precision: 20, scale: 3, default: "0.0"
    t.decimal "subtotal", precision: 20, scale: 3, default: "0.0"
    t.decimal "subtoin", precision: 20, scale: 3, default: "0.0"
    t.decimal "subtotout", precision: 20, scale: 3, default: "0.0"
    t.decimal "potfaktur", precision: 25, scale: 10, default: "0.0"
    t.decimal "pajakin", precision: 20, scale: 3, default: "0.0"
    t.decimal "prpajakin", precision: 10, scale: 3, default: "0.0"
    t.decimal "pajakout", precision: 20, scale: 3, default: "0.0"
    t.decimal "prpajakout", precision: 10, scale: 3, default: "0.0"
    t.decimal "biayalain", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalakhir", precision: 20, scale: 3, default: "0.0"
    t.string "carabayar", limit: 20
    t.decimal "jmltunai", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkredit", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmldebit", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkk", precision: 20, scale: 3, default: "0.0"
    t.decimal "dppesanan", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi1", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi2", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi3", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi4", precision: 20, scale: 3, default: "0.0"
    t.string "nofp", limit: 100
    t.string "acc_potongan", limit: 30, comment: "POTONGAN"
    t.string "acc_pajak_in", limit: 30, comment: "PAJAK MASUKAN"
    t.string "acc_pajak", limit: 30, comment: "PAJAK KELUARAN"
    t.string "acc_biayalain", limit: 30, comment: "BIAYA"
    t.string "acc_tunai", limit: 30, comment: "BAYAR TUNAI"
    t.string "acc_kredit", limit: 30, comment: "BAYAR KREDIT"
    t.string "acc_sales", limit: 30, comment: "SALES"
    t.string "acc_hpp", limit: 30
    t.string "acc_debit", limit: 30
    t.string "acc_kk", limit: 30
    t.string "acc_deposit", limit: 30, comment: "BAYAR DEPOSIT"
    t.string "acc_dppesanan", limit: 30
    t.string "acc_biaya_pot", limit: 30
    t.datetime "byr_krd_jt"
    t.string "byr_krd_no", limit: 30
    t.string "byr_debit_bank", limit: 30
    t.string "byr_kk_bank", limit: 30
    t.string "byr_debit_no", limit: 100
    t.string "byr_kk_no", limit: 100
    t.decimal "krd_jml_pot", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_byr", precision: 20, scale: 3, default: "0.0"
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd"
    t.date "tanggal_sa"
    t.boolean "biaya_msk_total"
    t.decimal "potnomfaktur", precision: 20, scale: 3, default: "0.0"
    t.string "compname", limit: 255
    t.string "shiftkerja", limit: 20
    t.decimal "point_ik", precision: 20, scale: 3, default: "0.0"
    t.integer "point_sts", default: 0
    t.string "notrsretur", limit: 100
    t.string "point_notrans", limit: 50
    t.decimal "jmldeposit", precision: 20, scale: 3, default: "0.0"
    t.string "ppn", limit: 30
    t.boolean "byr_komisi1"
    t.boolean "byr_komisi2"
    t.boolean "byr_komisi3"
    t.boolean "byr_komisi4"
    t.boolean "bc_trf_sts", default: false
    t.boolean "status_online", default: false
    t.string "compname_online", limit: 255
    t.string "user_online", limit: 50
    t.decimal "jmlemoney", precision: 20, scale: 3, default: "0.0"
    t.string "byr_emoney_no", limit: 100
    t.string "byr_emoney_prod", limit: 30
    t.string "acc_emoney", limit: 30
    t.string "acc_sales_hut", limit: 30, default: ""
    t.string "opsikembalian", limit: 5
    t.decimal "jmlopkembali", precision: 20, scale: 3
    t.string "acc_donasi", limit: 30
    t.decimal "krd_jml_pot_ls", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_byr_ls", precision: 20, scale: 3, default: "0.0"
    t.index ["kantordari"], name: "kantordaritkt"
    t.index ["kodekantor"], name: "kodekantor3tkt"
    t.index ["kodesales"], name: "kodesalestkt"
    t.index ["kodesales2"], name: "kodesales2tkt"
    t.index ["kodesales3"], name: "kodesales3tkt"
    t.index ["kodesupel"], name: "kodesupel1tkt"
    t.index ["matauang"], name: "matauang6tkt"
  end

  create_table "tbl_itrdt", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.integer "nobaris", default: 0
    t.string "notransaksi", limit: 50
    t.string "kodeitem", limit: 100
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.string "satuan", limit: 50
    t.datetime "dateupd", precision: nil
    t.text "detinfo"
    t.decimal "jmlkonversi", precision: 20, scale: 3, default: "0.0"
    t.decimal "hppdasar", precision: 35, scale: 20, default: "0.0"
    t.datetime "tglexp"
    t.string "kodeprod", limit: 100
    t.index ["kodeitem"], name: "kodeitem12"
    t.index ["notransaksi"], name: "notransaksi5"
    t.index ["satuan"], name: "satuan4"
  end

  create_table "tbl_itrhd", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodekantor", limit: 50
    t.string "kantordari", limit: 50
    t.string "kantortujuan", limit: 50
    t.datetime "tanggal", precision: nil
    t.string "tipe", limit: 20
    t.text "keterangan"
    t.string "acc_persediaan", limit: 30
    t.decimal "totalitem", precision: 20, scale: 3, default: "0.0"
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd", precision: nil
    t.string "shiftkerja", limit: 20
    t.string "mob_owner_id", limit: 20
    t.boolean "mob_trf_sts"
    t.boolean "bc_trf_sts", default: false, comment: "status transfer beda cabang. digunakan oleh web app"
    t.boolean "status_online", default: false
    t.string "compname_online", limit: 255
    t.string "user_online", limit: 50
    t.index ["acc_persediaan"], name: "acc_hpp"
    t.index ["kantordari"], name: "kantordari1"
    t.index ["kantortujuan"], name: "kantortujuan1"
    t.index ["kodekantor"], name: "kodekantor9"
  end

  create_table "tbl_kantor", primary_key: "kodekantor", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "fungsi", limit: 20
    t.string "namakantor", limit: 200
    t.text "alamat"
    t.string "notelepon", limit: 150
    t.string "fax", limit: 150
    t.boolean "cabang", default: false
    t.string "kodeacc", limit: 30
    t.boolean "mobile", default: false
    t.boolean "stspakai", default: false
    t.decimal "nompajak", precision: 20, scale: 3, default: "0.0"
    t.string "stsaktif", limit: 15, default: "Y"
    t.string "whatsapp", limit: 20
    t.string "email", limit: 100
    t.index ["kodekantor"], name: "kodekantor10"
  end

  create_table "tbl_kaslaci", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "nama_user", limit: 50, null: false
    t.string "shift", limit: 10
    t.decimal "kas_awal", precision: 20, scale: 3, default: "0.0"
    t.decimal "kas_masuk", precision: 20, scale: 3, default: "0.0"
    t.decimal "kas_akhir", precision: 20, scale: 3, default: "0.0"
    t.datetime "wkt_mulai"
    t.datetime "wkt_akhir"
    t.boolean "login_flag", default: false
    t.decimal "kas_keluar", precision: 20, scale: 3
    t.string "nama_komputer", limit: 20
  end

  create_table "tbl_kaslacidt", id: false, force: :cascade do |t|
    t.string "notransaksi", limit: 50, null: false
    t.string "nama_pengambil", limit: 50
    t.decimal "kas_keluar", precision: 20, scale: 3
    t.string "keterangan_p", limit: 100
    t.string "iddetail", limit: 200, null: false
  end

  create_table "tbl_logaktivitas_akuntansi", id: { type: :string, limit: 100 }, force: :cascade do |t|
    t.string "object", limit: 100, null: false
    t.string "value", limit: 100
    t.string "description", limit: 100, null: false
    t.string "iddetail", limit: 150
    t.string "notransaksi", limit: 100
    t.string "kodeacc", limit: 50
    t.string "cmd", limit: 20, null: false
    t.string "user1", limit: 30, null: false
    t.string "shift", limit: 20
    t.string "compname", limit: 200, null: false
    t.string "kodekantor", limit: 20, null: false
    t.datetime "dateupd", precision: nil, null: false
    t.string "nama_app", limit: 20
    t.string "versi_app", limit: 100
  end

  create_table "tbl_logaktivitas_impor", id: { type: :string, limit: 100 }, force: :cascade do |t|
    t.string "object", limit: 100, null: false
    t.string "value", limit: 100
    t.string "description", limit: 100, null: false
    t.string "user1", limit: 30, null: false
    t.string "shift", limit: 20
    t.string "compname", limit: 200, null: false
    t.string "kodekantor", limit: 20, null: false
    t.datetime "dateupd", null: false
    t.string "nama_app", limit: 20
    t.string "versi_app", limit: 100
  end

  create_table "tbl_logaktivitas_master", id: { type: :string, limit: 100 }, force: :cascade do |t|
    t.string "object", limit: 100, null: false
    t.string "value", limit: 100
    t.string "description", limit: 100, null: false
    t.string "cmd", limit: 20, null: false
    t.string "user1", limit: 30, null: false
    t.string "shift", limit: 20
    t.string "compname", limit: 200, null: false
    t.string "kodekantor", limit: 20, null: false
    t.datetime "dateupd", null: false
    t.string "nama_app", limit: 20
    t.string "versi_app", limit: 100
  end

  create_table "tbl_logaktivitas_sistem", id: { type: :string, limit: 100 }, force: :cascade do |t|
    t.string "object", limit: 100, null: false
    t.string "value", limit: 100
    t.string "description", limit: 100, null: false
    t.string "iddetail", limit: 150
    t.string "notransaksi", limit: 100
    t.string "cmd", limit: 20, null: false
    t.string "user1", limit: 30, null: false
    t.string "shift", limit: 20
    t.string "kodekantor", limit: 20, null: false
    t.string "nama_app", limit: 20
    t.string "versi_app", limit: 100
    t.datetime "dateupd", precision: nil, null: false
    t.string "compname", limit: 200, null: false
  end

  create_table "tbl_logaktivitas_transaksi", id: { type: :string, limit: 100 }, force: :cascade do |t|
    t.string "object", limit: 100, null: false
    t.string "value", limit: 100
    t.string "description", limit: 100, null: false
    t.string "iddetail", limit: 150
    t.string "notransaksi", limit: 100
    t.string "cmd", limit: 20, null: false
    t.string "user1", limit: 30, null: false
    t.string "shift", limit: 20
    t.string "kodekantor", limit: 20, null: false
    t.datetime "dateupd", precision: nil, null: false
    t.string "compname", limit: 200, null: false
    t.string "nama_app", limit: 20
    t.string "versi_app", limit: 100
  end

  create_table "tbl_matauang", primary_key: "matauang", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "ketmatauang", limit: 100
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.boolean "utama", default: false
    t.string "acc_hutang", limit: 50
    t.string "acc_piutang", limit: 50
    t.string "acc_byrtunai", limit: 50
    t.string "acc_byrbank", limit: 50
    t.string "tipe", limit: 5
    t.index ["acc_hutang"], name: "acc_hutang"
    t.index ["acc_piutang"], name: "acc_piutang"
  end

  create_table "tbl_mu_ratesa", id: false, force: :cascade do |t|
    t.string "matauang", limit: 50
    t.datetime "tanggal", precision: nil
    t.decimal "rate", precision: 35, scale: 20
  end

  create_table "tbl_ongkir", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "expedisi", limit: 50
    t.string "kota", limit: 100
    t.string "negara", limit: 100
    t.decimal "biaya1", precision: 20, scale: 3, default: "0.0"
    t.decimal "biaya2", precision: 20, scale: 3, default: "0.0"
    t.decimal "biaya3", precision: 20, scale: 3, default: "0.0"
    t.text "keterangan"
    t.string "kotatujuan", limit: 100
    t.string "kodekantor", limit: 50
  end

  create_table "tbl_pengiriman", primary_key: "notrs", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "idalamat_kirim", limit: 150
    t.string "idongkir_kurir", limit: 150
    t.decimal "berat", precision: 20
    t.decimal "paket", precision: 20
    t.string "statuskirim", limit: 50
    t.datetime "tanggalkirim"
    t.string "noresi", limit: 150
    t.string "kurir", limit: 150
    t.string "jasa", limit: 50
    t.string "layanan", limit: 50
    t.decimal "total", precision: 20
    t.boolean "opsioffline"
  end

  create_table "tbl_perkiraan", primary_key: "kodeacc", id: { type: :string, limit: 30 }, force: :cascade do |t|
    t.string "parentacc", limit: 30
    t.string "kelompok", limit: 2
    t.string "tipe", limit: 2
    t.string "namaacc", limit: 200
    t.string "matauang", limit: 50
    t.datetime "dateupd", precision: nil
    t.boolean "kasbank", default: false
    t.boolean "defmuutm", default: false
    t.index ["matauang"], name: "matauang9"
  end

  create_table "tbl_perksetting", primary_key: ["acckantor", "accsetting"], force: :cascade do |t|
    t.string "accsetting", limit: 50, null: false
    t.string "kodeacc", limit: 30
    t.string "acckantor", limit: 50, null: false
  end

  create_table "tbl_pesandt", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.integer "nobaris", default: 0
    t.string "notransaksi", limit: 50
    t.string "kodeitem", limit: 100
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlterima", precision: 20, scale: 3, default: "0.0"
    t.string "satuan", limit: 50
    t.decimal "harga", precision: 35, scale: 20, default: "0.0"
    t.decimal "potongan", precision: 35, scale: 20, default: "0.0"
    t.decimal "total", precision: 20, scale: 3, default: "0.0"
    t.decimal "pajak", precision: 20, scale: 3, default: "0.0"
    t.datetime "dateupd", precision: nil
    t.text "detinfo"
    t.string "sistemhargajual", limit: 1
    t.decimal "jmlkonversi", precision: 20, scale: 3, default: "0.0"
    t.datetime "tglexp"
    t.string "kodeprod", limit: 100
    t.index ["kodeitem"], name: "kodeitem13"
    t.index ["notransaksi"], name: "notransaksi6"
  end

  create_table "tbl_pesanhd", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodekantor", limit: 50
    t.string "kantortujuan", limit: 50
    t.datetime "tanggal", precision: nil
    t.string "tipe", limit: 20
    t.datetime "tanggalkirim", precision: nil
    t.string "jenis", limit: 20
    t.string "kodesupel", limit: 50
    t.string "kodesales", limit: 50
    t.string "kodesales2", limit: 50
    t.string "kodesales3", limit: 50
    t.string "kodesales4", limit: 50
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.text "keterangan"
    t.decimal "komisi1", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi2", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi3", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi4", precision: 20, scale: 3
    t.decimal "totalitem", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalterima", precision: 20, scale: 3, default: "0.0"
    t.decimal "subtotal", precision: 20, scale: 3, default: "0.0"
    t.decimal "potfaktur", precision: 25, scale: 10, default: "0.0"
    t.decimal "pajak", precision: 20, scale: 3, default: "0.0"
    t.decimal "biayalain", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalakhir", precision: 20, scale: 3, default: "0.0"
    t.boolean "biaya_msk_total"
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd", precision: nil
    t.decimal "potnomfaktur", precision: 20, scale: 3, default: "0.0"
    t.decimal "prpajak", precision: 10, scale: 3, default: "0.0"
    t.decimal "dppesanan", precision: 20, scale: 3, default: "0.0"
    t.decimal "dppesananbyr", precision: 20, scale: 3, default: "0.0"
    t.string "acc_dppesanan", limit: 30
    t.string "acc_dpkas", limit: 30
    t.string "ppn", limit: 30
    t.boolean "bc_trf_sts", default: false
    t.decimal "prpotfaktur", precision: 25, scale: 10
    t.string "acc_biaya_pot", limit: 30
    t.string "opsikirim", limit: 5
    t.index ["kantortujuan"], name: "kantortujuan2"
    t.index ["kodekantor"], name: "kodekantor11"
    t.index ["kodesupel"], name: "kodesupel2"
    t.index ["matauang"], name: "matauang10"
  end

  create_table "tbl_pesanrakitan", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "iddetailtrs", limit: 150
    t.string "notransaksi", limit: 50
    t.string "tipe", limit: 20
    t.string "kodeitem", limit: 100
    t.string "kodeitemrakitan", limit: 100
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.string "satuan", limit: 50
    t.decimal "harga", precision: 20, scale: 3, default: "0.0"
    t.decimal "total", precision: 20, scale: 3, default: "0.0"
    t.decimal "jumlahtrs", precision: 20, scale: 3, default: "0.0"
    t.string "satuantrs", limit: 50
    t.datetime "dateupd", precision: nil
    t.string "jenisrakit", limit: 20
    t.decimal "jmlkonversi", precision: 20, scale: 3, default: "0.0"
  end

  create_table "tbl_point_sa", id: false, force: :cascade do |t|
    t.string "kodesupel", limit: 50, null: false
    t.string "kodekantor", limit: 50
    t.string "notransaksi", limit: 50
    t.datetime "tanggal", precision: nil
    t.string "tipe", limit: 20
    t.decimal "point_ik", precision: 20, scale: 3, default: "0.0"
  end

  create_table "tbl_pointambil", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "tipe", limit: 50
    t.datetime "tanggal"
    t.datetime "periodetgl1"
    t.datetime "periodetgl2"
    t.decimal "jmlambil", precision: 20, default: "0"
    t.string "kodesupel", limit: 50
    t.text "keterangan"
    t.string "kodekantor", limit: 50
  end

  create_table "tbl_rb_hutang", id: false, force: :cascade do |t|
    t.string "noretur", limit: 50
    t.string "notrspot", limit: 50
    t.decimal "jmlpot", precision: 20, scale: 3, default: "0.0"
    t.index ["noretur"], name: "noretur"
    t.index ["notrspot"], name: "notrs"
  end

  create_table "tbl_ref_retur", id: false, force: :cascade do |t|
    t.string "iddetail", limit: 150, null: false
    t.string "notransaksi", limit: 50
    t.string "iddetailim", limit: 150
    t.string "kodeitem", limit: 150
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
  end

  create_table "tbl_request_upload_queue", primary_key: "idupload", id: { type: :string, limit: 100 }, force: :cascade do |t|
    t.datetime "entry_date", precision: nil
    t.string "modul_type", limit: 50
    t.string "modul_key_value", limit: 255
    t.string "modul_key_oldvalue", limit: 255
    t.string "save_type", limit: 50
    t.integer "flag_upload"
    t.string "ret_id", limit: 20
    t.text "ret_msg"
  end

  create_table "tbl_rj_piutang", id: false, force: :cascade do |t|
    t.string "noretur", limit: 50
    t.string "notrspot", limit: 50
    t.decimal "jmlpot", precision: 20, scale: 3, default: "0.0"
    t.index ["noretur"], name: "noretur1"
    t.index ["notrspot"], name: "notrs1"
  end

  create_table "tbl_sandi", id: false, force: :cascade do |t|
    t.string "angka", limit: 2
    t.string "huruf", limit: 10
  end

  create_table "tbl_settingpel", id: false, force: :cascade do |t|
    t.integer "ptipe", default: 1
    t.decimal "pkelipatan", precision: 20, scale: 3, default: "0.0"
    t.decimal "pnilaitukar", precision: 20, scale: 3, default: "0.0"
    t.datetime "pmasadari", precision: 0
    t.datetime "pmasasampai", precision: 0
    t.datetime "pmtukardari", precision: 0
    t.datetime "pmtukarsampai", precision: 0
    t.integer "ppotberlaku", default: 0
    t.string "mnote1", limit: 255
    t.string "mnote2", limit: 255
    t.boolean "pumumnopoin", default: false
    t.datetime "pmdapatdari", precision: nil
    t.datetime "pmdapatsampai", precision: nil
    t.string "mnote3", limit: 255
    t.boolean "ppointopot", default: false
    t.string "mnote4", limit: 255
  end

  create_table "tbl_supel", primary_key: ["kode", "tipe"], force: :cascade do |t|
    t.string "kode", limit: 50, null: false
    t.string "tipe", limit: 2, null: false
    t.string "nama", limit: 150
    t.text "alamat"
    t.string "kota", limit: 100
    t.string "provinsi", limit: 100
    t.string "kodepos", limit: 20
    t.string "negara", limit: 100
    t.string "telepon", limit: 200
    t.string "fax", limit: 200
    t.string "kontak", limit: 200
    t.string "email", limit: 200
    t.string "matauang", limit: 50
    t.string "norek", limit: 100
    t.string "atasnama", limit: 100
    t.string "bank", limit: 100
    t.text "keterangan"
    t.decimal "limitjmlhupi", precision: 20, scale: 3, default: "0.0"
    t.integer "limitharihupi", default: 0
    t.string "tipepot", limit: 5
    t.string "kgrup", limit: 20
    t.integer "pilkomisi", default: 1
    t.integer "piljmlkomisi", default: 1
    t.decimal "komisipr", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisinom", precision: 20, scale: 3, default: "0.0"
    t.string "npwp", limit: 100
    t.integer "harijt", default: 0
    t.string "kdwilayah", limit: 50
    t.string "kdsubwil", limit: 50
    t.string "kdsales", limit: 50
    t.decimal "maxjmlkredit", precision: 20, scale: 3, default: "0.0"
    t.string "syspajak", limit: 10
    t.string "opsyspajak", limit: 10
    t.decimal "nompajak", precision: 20, scale: 3
    t.string "nik", limit: 50
    t.string "nama_npwp", limit: 150
    t.text "alamat_npwp"
    t.datetime "tgl_lahir", precision: nil
    t.string "opsikredit", limit: 5, default: "Y"
    t.string "acc_kredit", limit: 30
    t.string "stsaktif", limit: 15, default: "Y"
    t.boolean "cekbglunas", default: false
    t.index ["kode"], name: "kode"
    t.index ["kode"], name: "tbl_supel_kode_key", unique: true
    t.index ["matauang"], name: "tbl_supplier_fk_mu1"
  end

  create_table "tbl_supel_subwil", primary_key: "kode", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "subwilayah", limit: 250
  end

  create_table "tbl_supel_wil", primary_key: "kode", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "wilayah", limit: 250
  end

  create_table "tbl_supelgrup", primary_key: "kgrup", id: { type: :string, limit: 20 }, force: :cascade do |t|
    t.string "grup", limit: 100
    t.decimal "potongan", precision: 20, scale: 3, default: "0.0"
    t.integer "levelharga"
    t.decimal "kelipatanpoin", precision: 20, scale: 3, default: "0.0"
  end

  create_table "tbl_tagihandt", id: false, force: :cascade do |t|
    t.string "iddetail", limit: 100
    t.string "notransaksi", limit: 200
    t.decimal "jumlah", precision: 20, scale: 3
    t.string "idko_dt", limit: 20
  end

  create_table "tbl_tagihikdt", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.integer "nobaris", default: 0
    t.string "notransaksi", limit: 50
    t.string "kodeitem", limit: 100
    t.decimal "jumlah", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlpesan", precision: 20, scale: 3, default: "0.0"
    t.string "satuan", limit: 50
    t.decimal "harga", precision: 20, scale: 3, default: "0.0"
    t.decimal "potongan", precision: 35, scale: 20, default: "0.0"
    t.decimal "potongan2", precision: 35, scale: 20, default: "0.0"
    t.decimal "potongan3", precision: 35, scale: 20, default: "0.0"
    t.decimal "potongan4", precision: 35, scale: 20, default: "0.0"
    t.decimal "total", precision: 20, scale: 3, default: "0.0"
    t.decimal "pajak", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlrmasuk", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkeluar", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlrkeluar", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlsisa", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkonsibayar", precision: 20, scale: 3, default: "0.0"
    t.string "idorder", limit: 150
    t.datetime "dateupd"
    t.string "idtrskonsinyasi", limit: 150
    t.decimal "jmlretur", precision: 20, scale: 3, default: "0.0"
    t.text "detinfo"
    t.string "notrskonsinyasi", limit: 100
    t.decimal "jmlkonversi", precision: 50, scale: 3
    t.string "iddetailtrs", limit: 150
    t.integer "xx"
    t.datetime "tglexp"
    t.string "kodeprod", limit: 100
    t.index ["kodeitem"], name: "kodeitem1_tko"
    t.index ["notransaksi"], name: "tbl_ikdt_ikhd_tko"
  end

  create_table "tbl_tagihikhd", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodekantor", limit: 50
    t.string "kantordari", limit: 50
    t.datetime "tanggal"
    t.string "tipe", limit: 20
    t.string "notrsorder", limit: 50
    t.string "kodesupel", limit: 50
    t.string "kodesales", limit: 50
    t.string "kodesales2", limit: 50
    t.string "kodesales3", limit: 50
    t.string "kodesales4", limit: 50
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.text "keterangan"
    t.decimal "totalitem", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalitempesan", precision: 20, scale: 3, default: "0.0"
    t.decimal "subtotal", precision: 20, scale: 3, default: "0.0"
    t.decimal "potfaktur", precision: 25, scale: 10, default: "0.0"
    t.decimal "pajak", precision: 20, scale: 3, default: "0.0"
    t.decimal "biayalain", precision: 20, scale: 3, default: "0.0"
    t.decimal "potnomfaktur", precision: 20, scale: 3, default: "0.0"
    t.decimal "dppesanan", precision: 20, scale: 3, default: "0.0"
    t.decimal "prpajak", precision: 10, scale: 3, default: "0.0"
    t.decimal "totalakhir", precision: 20, scale: 3, default: "0.0"
    t.string "carabayar", limit: 20
    t.decimal "jmltunai", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkredit", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmldebit", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkk", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi1", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi2", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi3", precision: 20, scale: 3, default: "0.0"
    t.decimal "komisi4", precision: 20, scale: 3, default: "0.0"
    t.decimal "point_ik", precision: 20, scale: 3, default: "0.0"
    t.integer "point_sts", default: 0
    t.string "nofp", limit: 100
    t.string "ppn", limit: 30
    t.string "notrsretur", limit: 100
    t.string "acc_potongan", limit: 30, comment: "POTONGAN"
    t.string "acc_pajak", limit: 30, comment: "PAJAK"
    t.string "acc_biayalain", limit: 30, comment: "BIAYA"
    t.string "acc_tunai", limit: 30, comment: "BAYAR TUNAI"
    t.string "acc_kredit", limit: 30, comment: "BAYAR KREDIT"
    t.string "acc_sales", limit: 30, comment: "SALES"
    t.string "acc_hpp", limit: 30
    t.string "acc_debit", limit: 30
    t.string "acc_kk", limit: 30
    t.string "acc_dppesanan", limit: 30
    t.string "acc_biaya_pot", limit: 30
    t.datetime "byr_krd_jt"
    t.string "byr_krd_no", limit: 30
    t.string "byr_debit_bank", limit: 30
    t.string "byr_kk_bank", limit: 30
    t.string "byr_debit_no", limit: 100
    t.string "byr_kk_no", limit: 100
    t.decimal "krd_jml_pot", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_byr", precision: 20, scale: 3, default: "0.0"
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd"
    t.date "tanggal_sa"
    t.boolean "biaya_msk_total"
    t.string "compname", limit: 255
    t.string "shiftkerja", limit: 20
    t.boolean "byr_komisi1"
    t.boolean "byr_komisi2"
    t.boolean "byr_komisi3"
    t.boolean "byr_komisi4"
    t.string "point_notrans", limit: 50
    t.string "notransaksi_ko", limit: 50
    t.boolean "bc_trf_sts", default: false
    t.string "mode_tagih", limit: 5
    t.index ["kantordari"], name: "kantordari_tko"
    t.index ["kodekantor"], name: "kodekantor3_tko"
    t.index ["kodesupel"], name: "kodesupel1_tko"
    t.index ["matauang"], name: "matauang6_tko"
  end

  create_table "tbl_tagihimdt", primary_key: "iddetail", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.integer "nobaris", default: 0
    t.string "notransaksi", limit: 50
    t.string "kodeitem", limit: 100
    t.decimal "jmlkonsi", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkonsiretur", precision: 20, scale: 3, default: "0.0"
    t.string "satuan", limit: 50
    t.decimal "harga", precision: 20, scale: 3, default: "0.0"
    t.decimal "potongan", precision: 35, scale: 20, default: "0.0"
    t.decimal "total", precision: 20, scale: 3, default: "0.0"
    t.decimal "pajak", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmllaku", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlreturjual", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlsisa", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkonsibayar", precision: 20, scale: 3, default: "0.0"
    t.datetime "tglexp"
    t.string "idtrsretur", limit: 150
    t.string "kodeprod", limit: 100
    t.string "idorder", limit: 150
    t.datetime "dateupd"
    t.string "sakantor", limit: 50
    t.text "detinfo"
    t.decimal "pothutang", precision: 20, scale: 3
    t.string "notrsretur", limit: 100
    t.decimal "jmlkonversi", precision: 20, scale: 3
    t.decimal "nom_pajak", precision: 20, scale: 3
    t.decimal "jmlkeluar", precision: 20, scale: 3
    t.index ["iddetail"], name: "iddetail1_tki"
    t.index ["kodeitem"], name: "kodeitem3_tki"
    t.index ["notransaksi"], name: "tbl_belidt_belihd1_tki"
  end

  create_table "tbl_tagihimhd", primary_key: "notransaksi", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.string "kodekantor", limit: 50
    t.string "kantortujuan", limit: 50
    t.datetime "tanggal"
    t.string "tipe", limit: 20
    t.string "notrsorder", limit: 50
    t.string "kodesupel", limit: 50
    t.string "matauang", limit: 50
    t.decimal "rate", precision: 35, scale: 20, default: "0.0"
    t.text "keterangan"
    t.decimal "totalitem", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalitempesan", precision: 20, scale: 3, default: "0.0"
    t.decimal "subtotal", precision: 20, scale: 3, default: "0.0"
    t.decimal "potfaktur", precision: 25, scale: 10, default: "0.0"
    t.decimal "pajak", precision: 20, scale: 3, default: "0.0"
    t.decimal "biayalain", precision: 20, scale: 3, default: "0.0"
    t.decimal "totalakhir", precision: 20, scale: 3, default: "0.0"
    t.string "carabayar", limit: 20
    t.decimal "jmltunai", precision: 20, scale: 3, default: "0.0"
    t.decimal "jmlkredit", precision: 20, scale: 3, default: "0.0"
    t.string "acc_potongan", limit: 30, comment: "POTONGAN"
    t.string "acc_pajak", limit: 30, comment: "PAJAK"
    t.string "acc_biayalain", limit: 30, comment: "BIAYA"
    t.string "acc_tunai", limit: 30
    t.string "acc_kredit", limit: 30
    t.string "acc_hpp", limit: 30
    t.string "acc_tagihan", limit: 30
    t.string "acc_dppesanan", limit: 30
    t.string "acc_biaya_pot", limit: 30
    t.datetime "byr_krd_jt"
    t.string "byr_krd_no", limit: 30
    t.decimal "krd_jml_pot", precision: 20, scale: 3, default: "0.0"
    t.decimal "krd_jml_byr", precision: 20, scale: 3, default: "0.0"
    t.string "user1", limit: 50
    t.string "user2", limit: 50
    t.datetime "dateupd"
    t.date "tanggal_sa"
    t.boolean "biaya_msk_total"
    t.decimal "potnomfaktur", precision: 20, scale: 3, default: "0.0"
    t.string "compname", limit: 255
    t.string "shiftkerja", limit: 20
    t.decimal "prpajak", precision: 10, scale: 3, default: "0.0"
    t.decimal "dppesanan", precision: 20, scale: 3, default: "0.0"
    t.string "notrsretur", limit: 100
    t.string "ppn", limit: 30
    t.decimal "totallaku", precision: 20, scale: 3
    t.decimal "totalretur", precision: 20, scale: 3
    t.decimal "totalkonsinyasi", precision: 20, scale: 3
    t.boolean "bc_trf_sts", default: false
    t.index ["kantortujuan"], name: "kantortujuan_tki"
    t.index ["kodekantor"], name: "kodekantor4_tki"
    t.index ["kodesupel"], name: "kodesupplier2_tki"
    t.index ["matauang"], name: "matauang7_tki"
  end

  create_table "tbl_tmp", id: false, force: :cascade do |t|
    t.bigint "cntprsjurnal"
    t.integer "cntlevelrep", default: 0
    t.integer "cntsortrep", default: 0
    t.bigint "cnt_im", default: 0
  end

  create_table "tbl_user", primary_key: "userid", id: { type: :string, limit: 20 }, force: :cascade do |t|
    t.string "nama", limit: 150
    t.string "password", limit: 255
    t.string "tipe", limit: 5
    t.string "loginkantor", limit: 50
    t.string "kelompok", limit: 35
    t.boolean "loginshift"
    t.boolean "synchronized", comment: "apakah mobile user sudah dipakai atau belum"
    t.string "kodesales", limit: 50
    t.boolean "stslogin", default: false
  end

  create_table "tbl_userakses", id: false, force: :cascade do |t|
    t.string "klpakses", limit: 35
    t.string "modulid", limit: 50
    t.boolean "mopen", default: false
    t.boolean "mnew", default: false
    t.boolean "medit", default: false
    t.boolean "mdel", default: false
    t.boolean "mlock", default: false
    t.integer "urut", default: 0
    t.integer "kelompok"
    t.boolean "mlocktgl", default: false
  end

  create_table "tbl_usercus_acc", id: false, force: :cascade do |t|
    t.string "klpakses", limit: 35
    t.string "modulid", limit: 50
    t.string "customacc", limit: 50
    t.string "customval", limit: 50
  end

  create_table "tbl_userg", primary_key: "kelompok", id: { type: :string, limit: 30 }, force: :cascade do |t|
    t.integer "urut"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "username", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "jti", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.integer "role_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "work_schedules", force: :cascade do |t|
    t.integer "payroll_id", null: false
    t.integer "shift", null: false
    t.string "begin_work", null: false
    t.string "end_work", null: false
    t.integer "day_of_week", null: false
    t.integer "long_shift_per_week"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payroll_id"], name: "index_work_schedules_on_payroll_id"
  end

  add_foreign_key "access_authorizes", "roles"
  add_foreign_key "column_authorizes", "roles"
  add_foreign_key "discounts", "tbl_item", column: "item_code", primary_key: "kodeitem"
  add_foreign_key "discounts", "tbl_itemjenis", column: "blacklist_item_type_name", primary_key: "jenis"
  add_foreign_key "discounts", "tbl_itemjenis", column: "item_type_name", primary_key: "jenis"
  add_foreign_key "discounts", "tbl_itemmerek", column: "blacklist_brand_name", primary_key: "merek"
  add_foreign_key "discounts", "tbl_itemmerek", column: "brand_name", primary_key: "merek"
  add_foreign_key "discounts", "tbl_supel", column: "blacklist_supplier_code", primary_key: "kode"
  add_foreign_key "discounts", "tbl_supel", column: "supplier_code", primary_key: "kode"
  add_foreign_key "employee_attendances", "employees"
  add_foreign_key "employee_leaves", "employees"
  add_foreign_key "employees", "payrolls"
  add_foreign_key "employees", "roles"
  add_foreign_key "payroll_lines", "payrolls"
  add_foreign_key "payslip_lines", "payslips"
  add_foreign_key "payslips", "employees"
  add_foreign_key "payslips", "payrolls"
  add_foreign_key "settings", "users"
  add_foreign_key "tbl_acc_sa", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_acc_sa_matauang", on_update: :cascade
  add_foreign_key "tbl_acc_sa", "tbl_perkiraan", column: "kodeacc", primary_key: "kodeacc", name: "tbl_acc_sa_kodeacc", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_accdepositdt", "tbl_accdeposithd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_accdepodt_hd", on_update: :cascade
  add_foreign_key "tbl_accdepositdt", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_accdepodt_matauang", on_update: :cascade
  add_foreign_key "tbl_accdepositdt", "tbl_perkiraan", column: "kodeacc", primary_key: "kodeacc", name: "tbl_accdepodt_kodeacc", on_update: :cascade
  add_foreign_key "tbl_accdeposithd", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_accdepohd_kantor", on_update: :cascade
  add_foreign_key "tbl_accdeposithd", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_accdepohd_mu", on_update: :cascade
  add_foreign_key "tbl_accdeposithd", "tbl_perkiraan", column: "kodeacc", primary_key: "kodeacc", name: "tbl_accdepohd_acc1", on_update: :cascade
  add_foreign_key "tbl_accdeposithd", "tbl_perkiraan", column: "kodeaccto", primary_key: "kodeacc", name: "tbl_accdepohd_acc2", on_update: :cascade
  add_foreign_key "tbl_accdeposithd", "tbl_supel", column: "kodesupel", primary_key: "kode", name: "tbl_accdepohd_supel", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_accjurnal", "tbl_kantor", column: "kantor", primary_key: "kodekantor", name: "tbl_accjurnal_kantor", on_update: :cascade
  add_foreign_key "tbl_accjurnal", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_accjurnal_matauang", on_update: :cascade
  add_foreign_key "tbl_accjurnal", "tbl_perkiraan", column: "kodeacc", primary_key: "kodeacc", name: "tbl_accjurnal_kodeacc", on_update: :cascade
  add_foreign_key "tbl_acckasdt", "tbl_acckashd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_acckasdt_hd", on_update: :cascade
  add_foreign_key "tbl_acckasdt", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_acckasdt_matauang", on_update: :cascade
  add_foreign_key "tbl_acckasdt", "tbl_perkiraan", column: "kodeacc", primary_key: "kodeacc", name: "tbl_acckasdt_kodeacc", on_update: :cascade
  add_foreign_key "tbl_acckashd", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_acckashd_kantor", on_update: :cascade
  add_foreign_key "tbl_acckashd", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_acckashd_mu", on_update: :cascade
  add_foreign_key "tbl_acckashd", "tbl_perkiraan", column: "kodeacc", primary_key: "kodeacc", name: "tbl_acckashd_acc1", on_update: :cascade
  add_foreign_key "tbl_acckashd", "tbl_perkiraan", column: "kodeaccto", primary_key: "kodeacc", name: "tbl_acckashd_acc2", on_update: :cascade
  add_foreign_key "tbl_alamatkirim", "tbl_supel", column: "kode_supel", primary_key: "kode", name: "tbl_alamatkirim_supel", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_bank", "tbl_perkiraan", column: "acc_kd", primary_key: "kodeacc", name: "tbl_bank_acc_kd", on_update: :cascade
  add_foreign_key "tbl_bank", "tbl_perkiraan", column: "acc_kk", primary_key: "kodeacc", name: "tbl_bank_acc_kk", on_update: :cascade
  add_foreign_key "tbl_byrhutangdt", "tbl_byrhutanghd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_byrhutangdt_fk", on_update: :cascade
  add_foreign_key "tbl_byrhutangdt", "tbl_imhd", column: "notrsmasuk", primary_key: "notransaksi", name: "tbl_byrhutangdt_im", on_update: :cascade
  add_foreign_key "tbl_byrhutangdt", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_byrhutangdt_fk_mu", on_update: :cascade
  add_foreign_key "tbl_byrhutanghd", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_byrhutanghd_kantor", on_update: :cascade
  add_foreign_key "tbl_byrhutanghd", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_byrhutanghd_mu", on_update: :cascade
  add_foreign_key "tbl_byrhutanghd", "tbl_perkiraan", column: "acc_bayar", primary_key: "kodeacc", name: "tbl_byrhutanghd_kodeacc", on_update: :cascade
  add_foreign_key "tbl_byrhutanghd", "tbl_perkiraan", column: "acc_pot", primary_key: "kodeacc", name: "tbl_byrhutanghd_kodeacc_pot", on_update: :cascade
  add_foreign_key "tbl_byrhutanghd", "tbl_supel", column: "kodesupel", primary_key: "kode", name: "tbl_byrhutanghd_supel", on_update: :cascade
  add_foreign_key "tbl_byrhutangitem", "tbl_byrhutangdt", column: "iddetail", primary_key: "iddetail", name: "tbl_byrhutangitem_hutangdt", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_byrhutangitem", "tbl_byrhutanghd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_byrhutangitem_header", on_update: :cascade
  add_foreign_key "tbl_byrhutangitem", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_byrhutangitem_kodeitem", on_update: :cascade
  add_foreign_key "tbl_byrhutangkonsidt", "tbl_byrhutangkonsihd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_byrkonsiindt_notransaksi_fkey", on_update: :cascade
  add_foreign_key "tbl_byrhutangkonsidt", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_byrkonsiindt_matauang_fkey", on_update: :cascade
  add_foreign_key "tbl_byrhutangkonsidt", "tbl_tagihimhd", column: "notrsmasuk", primary_key: "notransaksi", name: "tbl_byrkonsiindt_notrsmasuk_fkey", on_update: :cascade
  add_foreign_key "tbl_byrhutangkonsihd", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_byrkonsiinhd_kodekantor_fkey", on_update: :cascade
  add_foreign_key "tbl_byrhutangkonsihd", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_byrkonsiinhd_matauang_fkey", on_update: :cascade
  add_foreign_key "tbl_byrhutangkonsihd", "tbl_perkiraan", column: "acc_bayar", primary_key: "kodeacc", name: "tbl_byrkonsiinhd_acc_bayar_fkey", on_update: :cascade
  add_foreign_key "tbl_byrhutangkonsihd", "tbl_perkiraan", column: "acc_pot", primary_key: "kodeacc", name: "tbl_byrhutangkonsihd_kodeacc_pot", on_update: :cascade
  add_foreign_key "tbl_byrhutangkonsihd", "tbl_supel", column: "kodesupel", primary_key: "kode", name: "tbl_byrkonsiinhd_kodesupel_fkey", on_update: :cascade
  add_foreign_key "tbl_byrkomisislsdt", "tbl_byrkomisislshd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_byrkomisislsdt_fk", on_update: :cascade
  add_foreign_key "tbl_byrkomisislsdt", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_byrkomisislsdt_fk_mu", on_update: :cascade
  add_foreign_key "tbl_byrkomisislshd", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_byrkomisislshd_kantor", on_update: :cascade
  add_foreign_key "tbl_byrkomisislshd", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_byrkomisislshd_mu", on_update: :cascade
  add_foreign_key "tbl_byrkomisislshd", "tbl_perkiraan", column: "acc_bayar", primary_key: "kodeacc", name: "tbl_byrkomisislshd_kodeacc", on_update: :cascade
  add_foreign_key "tbl_byrkomisislshd", "tbl_perkiraan", column: "acc_komisi_sales", primary_key: "kodeacc", name: "tbl_byrkomisislshd_acc_komisi_sales", on_update: :cascade
  add_foreign_key "tbl_byrkomisislshd", "tbl_supel", column: "kodesupel", primary_key: "kode", name: "tbl_byrkomisislshd_supel", on_update: :cascade
  add_foreign_key "tbl_byrpiutangdt", "tbl_byrpiutanghd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_byrpiutangdt_notrs", on_update: :cascade
  add_foreign_key "tbl_byrpiutangdt", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_byrpiutangdt_mu", on_update: :cascade
  add_foreign_key "tbl_byrpiutanghd", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_byrpiutanghd_kantor", on_update: :cascade
  add_foreign_key "tbl_byrpiutanghd", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_byrpiutanghd_mu", on_update: :cascade
  add_foreign_key "tbl_byrpiutanghd", "tbl_perkiraan", column: "acc_bayar", primary_key: "kodeacc", name: "tbl_byrpiutanghd_kodeacc", on_update: :cascade
  add_foreign_key "tbl_byrpiutanghd", "tbl_perkiraan", column: "acc_pot", primary_key: "kodeacc", name: "tbl_byrpiutanghd_kodeacc_pot", on_update: :cascade
  add_foreign_key "tbl_byrpiutanghd", "tbl_supel", column: "kodesupel", primary_key: "kode", name: "tbl_byrpiutanghd_supel", on_update: :cascade
  add_foreign_key "tbl_byrpiutangkonsidt", "tbl_byrpiutangkonsihd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_byrpiutangkonsidt_notransaksi_fkey", on_update: :cascade
  add_foreign_key "tbl_byrpiutangkonsidt", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_byrpiutangkonsidt_matauang_fkey", on_update: :cascade
  add_foreign_key "tbl_byrpiutangkonsidt", "tbl_tagihikhd", column: "notrsmasuk", primary_key: "notransaksi", name: "tbl_byrpiutangkonsidt_notrsmasuk_fkey", on_update: :cascade
  add_foreign_key "tbl_byrpiutangkonsihd", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_byrpiutangkonsihd_kodekantor_fkey", on_update: :cascade
  add_foreign_key "tbl_byrpiutangkonsihd", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_byrpiutangkonsihd_matauang_fkey", on_update: :cascade
  add_foreign_key "tbl_byrpiutangkonsihd", "tbl_perkiraan", column: "acc_bayar", primary_key: "kodeacc", name: "tbl_byrpiutangkonsihd_acc_bayar_fkey", on_update: :cascade
  add_foreign_key "tbl_byrpiutangkonsihd", "tbl_perkiraan", column: "acc_pot", primary_key: "kodeacc", name: "tbl_byrpiutangkonsihd_kodeacc_pot", on_update: :cascade
  add_foreign_key "tbl_byrpiutangkonsihd", "tbl_supel", column: "kodesupel", primary_key: "kode", name: "tbl_byrpiutangkonsihd_kodesupel_fkey", on_update: :cascade
  add_foreign_key "tbl_emoney", "tbl_perkiraan", column: "acc_prod", primary_key: "kodeacc", name: "tbl_emoney_acc_prod", on_update: :cascade
  add_foreign_key "tbl_formatnotr", "tbl_kantor", column: "kantor", primary_key: "kodekantor", name: "tbl_formatnotr_kantor", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_hupi_sa", "tbl_matauang", column: "kodemu", primary_key: "matauang", name: "tbl_hupi_sa_mu", on_update: :cascade
  add_foreign_key "tbl_hupi_sa", "tbl_perkiraan", column: "kode_acc", primary_key: "kodeacc", name: "tbl_hupi_sa_acc", on_update: :cascade
  add_foreign_key "tbl_hupi_sa", "tbl_supel", column: "kodesupel", primary_key: "kode", name: "tbl_hupi_sa_supel", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_ikdt", "tbl_ikhd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_ikdt_notransaksi", on_update: :cascade
  add_foreign_key "tbl_ikdt", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_ikdt_item", on_update: :cascade
  add_foreign_key "tbl_ikdt", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_ikdt_satuan", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_bank", column: "byr_debit_bank", primary_key: "kodebank", name: "tbl_ikhd_bank_kd", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_bank", column: "byr_kk_bank", primary_key: "kodebank", name: "tbl_ikhd_bank_kk", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_emoney", column: "byr_emoney_prod", primary_key: "kodeprod", name: "tbl_ikhd_emoney_prod", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_ikhd", column: "notrsretur", primary_key: "notransaksi", name: "tbl_ikhd_retur", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_kantor", column: "kantordari", primary_key: "kodekantor", name: "tbl_ikhd_kantordari", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_ikhd_kantor", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_ikhd_mu", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_perkiraan", column: "acc_biaya_pot", primary_key: "kodeacc", name: "tbl_ikhd_biaya_pot", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_perkiraan", column: "acc_biayalain", primary_key: "kodeacc", name: "tbl_ikhd_biaya", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_perkiraan", column: "acc_debit", primary_key: "kodeacc", name: "tbl_ikhd_accdebit", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_perkiraan", column: "acc_dppesanan", primary_key: "kodeacc", name: "tbl_ikhd_accdppsn", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_perkiraan", column: "acc_emoney", primary_key: "kodeacc", name: "tbl_ikhd_accemoney", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_perkiraan", column: "acc_hpp", primary_key: "kodeacc", name: "tbl_ikhd_hpp", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_perkiraan", column: "acc_kk", primary_key: "kodeacc", name: "tbl_ikhd_acckk", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_perkiraan", column: "acc_kredit", primary_key: "kodeacc", name: "tbl_ikhd_kredit", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_perkiraan", column: "acc_pajak", primary_key: "kodeacc", name: "tbl_ikhd_pajak", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_perkiraan", column: "acc_pend_pembulatan", primary_key: "kodeacc", name: "tbl_ikhd_accpendpembulatan", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_perkiraan", column: "acc_potongan", primary_key: "kodeacc", name: "tbl_ikhd_accpot", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_perkiraan", column: "acc_sales", primary_key: "kodeacc", name: "tbl_ikhd_accsales", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_perkiraan", column: "acc_tunai", primary_key: "kodeacc", name: "tbl_ikhd_tunai", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_supel", column: "kodesales", primary_key: "kode", name: "tbl_ikhd_sales", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_supel", column: "kodesales2", primary_key: "kode", name: "tbl_ikhd_sales2", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_supel", column: "kodesales3", primary_key: "kode", name: "tbl_ikhd_sales3", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_supel", column: "kodesales4", primary_key: "kode", name: "tbl_ikhd_sales4", on_update: :cascade
  add_foreign_key "tbl_ikhd", "tbl_supel", column: "kodesupel", primary_key: "kode", name: "tbl_ikhd_supel", on_update: :cascade
  add_foreign_key "tbl_ikrakitan", "tbl_ikdt", column: "iddetailtrs", primary_key: "iddetail", name: "tbl_ikrakitan_detailtrs", on_update: :cascade
  add_foreign_key "tbl_ikrakitan", "tbl_ikhd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_ikrakitan_notrs", on_update: :cascade
  add_foreign_key "tbl_ikrakitan", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_ikrakitan_item", on_update: :cascade
  add_foreign_key "tbl_ikrakitan", "tbl_item", column: "kodeitemrakitan", primary_key: "kodeitem", name: "tbl_ikrakitan_rakitan", on_update: :cascade
  add_foreign_key "tbl_ikrakitan", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_ikrakitan_satuan", on_update: :cascade
  add_foreign_key "tbl_imdt", "tbl_imhd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_belidt_belihd", on_update: :cascade
  add_foreign_key "tbl_imdt", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_belidt_item", on_update: :cascade
  add_foreign_key "tbl_imdt", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_imdt_satuan", on_update: :cascade
  add_foreign_key "tbl_imdt", "tbl_kantor", column: "sakantor", primary_key: "kodekantor", name: "tbl_imdt_fk_kantor", on_update: :cascade
  add_foreign_key "tbl_imhd", "tbl_imhd", column: "notrsretur", primary_key: "notransaksi", name: "tbl_imhd_retur", on_update: :cascade
  add_foreign_key "tbl_imhd", "tbl_kantor", column: "kantortujuan", primary_key: "kodekantor", name: "tbl_imhd_kantortjn", on_update: :cascade
  add_foreign_key "tbl_imhd", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_imhd_kantor", on_update: :cascade
  add_foreign_key "tbl_imhd", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_imhd_mu", on_update: :cascade
  add_foreign_key "tbl_imhd", "tbl_perkiraan", column: "acc_biaya_pot", primary_key: "kodeacc", name: "tbl_imhd_biaya_pot", on_update: :cascade
  add_foreign_key "tbl_imhd", "tbl_perkiraan", column: "acc_biayalain", primary_key: "kodeacc", name: "tbl_imhd_accbiaya", on_update: :cascade
  add_foreign_key "tbl_imhd", "tbl_perkiraan", column: "acc_dppesanan", primary_key: "kodeacc", name: "tbl_imhd_accdppsn", on_update: :cascade
  add_foreign_key "tbl_imhd", "tbl_perkiraan", column: "acc_hpp", primary_key: "kodeacc", name: "tbl_imhd_acchpp", on_update: :cascade
  add_foreign_key "tbl_imhd", "tbl_perkiraan", column: "acc_kredit", primary_key: "kodeacc", name: "tbl_imhd_acckredit", on_update: :cascade
  add_foreign_key "tbl_imhd", "tbl_perkiraan", column: "acc_pajak", primary_key: "kodeacc", name: "tbl_imhd_accpajak", on_update: :cascade
  add_foreign_key "tbl_imhd", "tbl_perkiraan", column: "acc_potongan", primary_key: "kodeacc", name: "tbl_imhd_accpot", on_update: :cascade
  add_foreign_key "tbl_imhd", "tbl_perkiraan", column: "acc_tunai", primary_key: "kodeacc", name: "tbl_imhd_acctunai", on_update: :cascade
  add_foreign_key "tbl_imhd", "tbl_supel", column: "kodesupel", primary_key: "kode", name: "tbl_imhd_supel", on_update: :cascade
  add_foreign_key "tbl_imrakitan", "tbl_imhd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_imrakitan_notrs", on_update: :cascade
  add_foreign_key "tbl_imrakitan", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_imrakitan_item", on_update: :cascade
  add_foreign_key "tbl_imrakitan", "tbl_item", column: "kodeitemrakitan", primary_key: "kodeitem", name: "tbl_imrakitan_rakitan", on_update: :cascade
  add_foreign_key "tbl_item", "tbl_itemjenis", column: "jenis", primary_key: "jenis", name: "tbl_item_jenis", on_update: :cascade
  add_foreign_key "tbl_item", "tbl_itemmerek", column: "merek", primary_key: "merek", name: "tbl_item_merek", on_update: :cascade
  add_foreign_key "tbl_item", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_item_satuan", on_update: :cascade
  add_foreign_key "tbl_item", "tbl_kantor", column: "dept", primary_key: "kodekantor", name: "tbl_item_dept_gudang", on_update: :cascade
  add_foreign_key "tbl_item", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_item_matauang", on_update: :cascade
  add_foreign_key "tbl_item", "tbl_perkiraan", column: "acc_byoverhead", primary_key: "kodeacc", name: "tbl_item_overhead"
  add_foreign_key "tbl_item", "tbl_perkiraan", column: "acc_bytenagakerja", primary_key: "kodeacc", name: "tbl_item_tenagakerja", on_update: :cascade
  add_foreign_key "tbl_item", "tbl_perkiraan", column: "acc_hpp", primary_key: "kodeacc", name: "tbl_item_acchpp", on_update: :cascade
  add_foreign_key "tbl_item", "tbl_perkiraan", column: "acc_jasa", primary_key: "kodeacc", name: "tbl_item_accjasa", on_update: :cascade
  add_foreign_key "tbl_item", "tbl_perkiraan", column: "acc_noninventory", primary_key: "kodeacc", name: "tbl_item_accnoninv", on_update: :cascade
  add_foreign_key "tbl_item", "tbl_perkiraan", column: "acc_pendapatan", primary_key: "kodeacc", name: "tbl_item_accpendpt", on_update: :cascade
  add_foreign_key "tbl_item", "tbl_perkiraan", column: "acc_perbahanbaku", primary_key: "kodeacc", name: "tbl_item_bahanbaku", on_update: :cascade
  add_foreign_key "tbl_item", "tbl_perkiraan", column: "acc_persediaan", primary_key: "kodeacc", name: "tbl_item_accpersdn", on_update: :cascade
  add_foreign_key "tbl_item", "tbl_supel", column: "supplier1", primary_key: "kode", name: "tbl_item_supplier", on_update: :cascade
  add_foreign_key "tbl_item_ik", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_item_ik_item", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_item_ik", "tbl_itemsatuan", column: "satuandasar", primary_key: "satuan", name: "tbl_item_ik_satuan", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_item_ik", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_item_ik_kantor", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_item_ikko", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_item_ikko_item", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_item_ikret", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_item_ikret_item", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_item_im", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_item_im_item", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_item_im", "tbl_itemsatuan", column: "satuandasar", primary_key: "satuan", name: "tbl_item_im_fk", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_item_im", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_item_im_kantor", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_item_im", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_item_im_mu", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_item_imret", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_item_imret_item", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_item_rekap", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_item_rekap_item", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_item_rekap", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_item_rekap_satuan", on_update: :cascade
  add_foreign_key "tbl_item_rekap", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_item_rekap_kantor", on_update: :cascade
  add_foreign_key "tbl_item_sa", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_item_sa_item", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_item_sa", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_item_sa_satuan", on_update: :cascade
  add_foreign_key "tbl_item_sa", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_item_sa_kantor", on_update: :cascade
  add_foreign_key "tbl_itemdisp", "tbl_itemjenis", column: "jenis", primary_key: "jenis", name: "tbl_itemdisp_jenis_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itemdisp", "tbl_itemmerek", column: "merek", primary_key: "merek", name: "tbl_itemdisp_merek_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itemdispdt", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_itemdispdt_kodeitem_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itemdispdt", "tbl_itemdisp", column: "iddiskon", primary_key: "iddiskon", name: "tbl_itemdispdt_iddiskon_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itemdispdt", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_itemdispdt_satuan_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itemhj", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_itemhj_item", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itemhj", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_itemhj_satuan", on_update: :cascade
  add_foreign_key "tbl_itemopname", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_itemopname_item", on_update: :cascade
  add_foreign_key "tbl_itemopname", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_itemopname_satuan", on_update: :cascade
  add_foreign_key "tbl_itemopname", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_itemopname_kantor", on_update: :cascade
  add_foreign_key "tbl_itemopname", "tbl_perkiraan", column: "kodeacc", primary_key: "kodeacc", name: "tbl_itemopname_acc", on_update: :cascade
  add_foreign_key "tbl_itempotongan", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_itempotongan_item", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itempotongan", "tbl_supelgrup", column: "kodegrup", primary_key: "kgrup", name: "tbl_itempotongan_grup", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itempromo", "tbl_itemjenis", column: "jenis", primary_key: "jenis", name: "tbl_itempromo_jenis_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itempromo", "tbl_itemmerek", column: "merek", primary_key: "merek", name: "tbl_itempromo_merek_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itempromodt", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_itempromodt_kodeitem_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itempromodt", "tbl_itempromo", column: "idpromo", primary_key: "idpromo", name: "tbl_itempromodt_idpromo_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itempromodt", "tbl_itemsatuan", column: "satuangratis", primary_key: "satuan", name: "tbl_itempromodt_satuangratis_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itempromodt", "tbl_itemsatuan", column: "satuanjual", primary_key: "satuan", name: "tbl_itempromodt_satuanjual_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itemrakitan", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_itemrakitan_item", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itemrakitan", "tbl_item", column: "kodeitemrakitan", primary_key: "kodeitem", name: "tbl_itemrakitan_itemsub", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itemrakitan", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_itemrakitan_fk", on_update: :cascade
  add_foreign_key "tbl_itemsatuanjml", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_itemsatuanjml_item", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itemsatuanjml", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_itemsatuanjml_satuan", on_update: :cascade
  add_foreign_key "tbl_itemserial", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_itemserial_kodeitem", on_update: :cascade
  add_foreign_key "tbl_itemserial", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_itemserial_kantor", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itemserial_kotag", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_itemserialkotag_kodeitem", on_update: :cascade
  add_foreign_key "tbl_itemserialdt", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_itemserialdt_kodeitem", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itemserialdt", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_itemserialdt_kantor", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itemserialmanage", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_itemsermanage_item", on_update: :cascade
  add_foreign_key "tbl_itemserialmanage", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_itemsermanage_iddetail_key", on_update: :cascade
  add_foreign_key "tbl_itemserialmanage", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_itemsermanage_kantor", on_update: :cascade
  add_foreign_key "tbl_itemstok", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_itemstok_item", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itemstok", "tbl_kantor", column: "kantor", primary_key: "kodekantor", name: "tbl_itemstok_kantor", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_itktdt", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_itktdt_item", on_update: :cascade
  add_foreign_key "tbl_itktdt", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_itktdt_satuan", on_update: :cascade
  add_foreign_key "tbl_itktdt", "tbl_itkthd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_itktdt_notransaksi", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_bank", column: "byr_debit_bank", primary_key: "kodebank", name: "tbl_itkthd_bank_kd", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_bank", column: "byr_kk_bank", primary_key: "kodebank", name: "tbl_itkthd_bank_kk", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_emoney", column: "byr_emoney_prod", primary_key: "kodeprod", name: "tbl_itkthd_emoney_prod", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_ikhd", column: "notrsretur", primary_key: "notransaksi", name: "tbl_itkthd_retur", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_kantor", column: "kantordari", primary_key: "kodekantor", name: "tbl_itkthd_kantordari", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_itkthd_kantor", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_itkthd_mu", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_perkiraan", column: "acc_biaya_pot", primary_key: "kodeacc", name: "tbl_itkthd_biaya_pot", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_perkiraan", column: "acc_biayalain", primary_key: "kodeacc", name: "tbl_itkthd_biaya", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_perkiraan", column: "acc_debit", primary_key: "kodeacc", name: "tbl_itkthd_accdebit", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_perkiraan", column: "acc_dppesanan", primary_key: "kodeacc", name: "tbl_itkthd_accdppsn", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_perkiraan", column: "acc_emoney", primary_key: "kodeacc", name: "tbl_itkthd_accemoney", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_perkiraan", column: "acc_hpp", primary_key: "kodeacc", name: "tbl_itkthd_hpp", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_perkiraan", column: "acc_kk", primary_key: "kodeacc", name: "tbl_itkthd_acckk", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_perkiraan", column: "acc_kredit", primary_key: "kodeacc", name: "tbl_itkthd_kredit", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_perkiraan", column: "acc_pajak", primary_key: "kodeacc", name: "tbl_itkthd_pajak_keluar", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_perkiraan", column: "acc_pajak_in", primary_key: "kodeacc", name: "tbl_itkthd_pajak_masuk"
  add_foreign_key "tbl_itkthd", "tbl_perkiraan", column: "acc_potongan", primary_key: "kodeacc", name: "tbl_itkthd_accpot", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_perkiraan", column: "acc_sales", primary_key: "kodeacc", name: "tbl_itkthd_accsales", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_perkiraan", column: "acc_tunai", primary_key: "kodeacc", name: "tbl_itkthd_tunai", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_supel", column: "kodesales", primary_key: "kode", name: "tbl_itkthd_sales", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_supel", column: "kodesales2", primary_key: "kode", name: "tbl_itkthd_sales2", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_supel", column: "kodesales3", primary_key: "kode", name: "tbl_itkthd_sales3", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_supel", column: "kodesales4", primary_key: "kode", name: "tbl_itkthd_sales4", on_update: :cascade
  add_foreign_key "tbl_itkthd", "tbl_supel", column: "kodesupel", primary_key: "kode", name: "tbl_itkthd_supel", on_update: :cascade
  add_foreign_key "tbl_itrdt", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_itrdt_item", on_update: :cascade
  add_foreign_key "tbl_itrdt", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_itrdt_satuan", on_update: :cascade
  add_foreign_key "tbl_itrdt", "tbl_itrhd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_itrdt_trhd", on_update: :cascade
  add_foreign_key "tbl_itrhd", "tbl_kantor", column: "kantordari", primary_key: "kodekantor", name: "tbl_itrhd_kantordari", on_update: :cascade
  add_foreign_key "tbl_itrhd", "tbl_kantor", column: "kantortujuan", primary_key: "kodekantor", name: "tbl_itrhd_kantortujuan", on_update: :cascade
  add_foreign_key "tbl_itrhd", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_itrhd_kantor", on_update: :cascade
  add_foreign_key "tbl_itrhd", "tbl_perkiraan", column: "acc_persediaan", primary_key: "kodeacc", name: "tbl_ithd_acchpp", on_update: :cascade
  add_foreign_key "tbl_kantor", "tbl_perkiraan", column: "kodeacc", primary_key: "kodeacc", name: "kodeacc_key", on_update: :cascade
  add_foreign_key "tbl_kaslacidt", "tbl_kaslaci", column: "notransaksi", primary_key: "notransaksi", name: "no_transaksi", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_mu_ratesa", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_mu_ratesa_fk", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_perkiraan", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_perkiraan_mu", on_update: :cascade
  add_foreign_key "tbl_perkiraan", "tbl_perkiraan", column: "parentacc", primary_key: "kodeacc", name: "tbl_perkiraan_parent", on_update: :cascade
  add_foreign_key "tbl_perksetting", "tbl_kantor", column: "acckantor", primary_key: "kodekantor", name: "tbl_perksetting_kantor", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_perksetting", "tbl_perkiraan", column: "kodeacc", primary_key: "kodeacc", name: "tbl_perksetting_perkiraan", on_update: :cascade, on_delete: :nullify
  add_foreign_key "tbl_pesandt", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_orderbelidt_fk_tblitem", on_update: :cascade
  add_foreign_key "tbl_pesandt", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_pesandt_satuan", on_update: :cascade
  add_foreign_key "tbl_pesandt", "tbl_pesanhd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_pesandt_hd", on_update: :cascade
  add_foreign_key "tbl_pesanhd", "tbl_kantor", column: "kantortujuan", primary_key: "kodekantor", name: "tbl_pesanhd_ktrtujuan", on_update: :cascade
  add_foreign_key "tbl_pesanhd", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_pesanhd_kantor", on_update: :cascade
  add_foreign_key "tbl_pesanhd", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_pesanbelihd_mu", on_update: :cascade
  add_foreign_key "tbl_pesanhd", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_pesanhd_mu", on_update: :cascade
  add_foreign_key "tbl_pesanhd", "tbl_perkiraan", column: "acc_biaya_pot", primary_key: "kodeacc", name: "tbl_pesanhd_biaya_pot", on_update: :cascade
  add_foreign_key "tbl_pesanhd", "tbl_perkiraan", column: "acc_dpkas", primary_key: "kodeacc", name: "tbl_pesanhd_accdpkas", on_update: :cascade
  add_foreign_key "tbl_pesanhd", "tbl_perkiraan", column: "acc_dppesanan", primary_key: "kodeacc", name: "tbl_pesanhd_accdppsn", on_update: :cascade
  add_foreign_key "tbl_pesanhd", "tbl_supel", column: "kodesales", primary_key: "kode", name: "tbl_pesanhd_sales", on_update: :cascade
  add_foreign_key "tbl_pesanhd", "tbl_supel", column: "kodesupel", primary_key: "kode", name: "tbl_pesanhd_supel", on_update: :cascade
  add_foreign_key "tbl_pesanrakitan", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_pesanrakitan_item", on_update: :cascade
  add_foreign_key "tbl_pesanrakitan", "tbl_item", column: "kodeitemrakitan", primary_key: "kodeitem", name: "tbl_pesanrakitan_rakitan", on_update: :cascade
  add_foreign_key "tbl_pesanrakitan", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_pesanrakitan_satuan", on_update: :cascade
  add_foreign_key "tbl_pesanrakitan", "tbl_pesandt", column: "iddetailtrs", primary_key: "iddetail", name: "tbl_pesanrakitan_dt", on_update: :cascade
  add_foreign_key "tbl_pesanrakitan", "tbl_pesanhd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_pesanrakitan_hd", on_update: :cascade
  add_foreign_key "tbl_point_sa", "tbl_supel", column: "kodesupel", primary_key: "kode", name: "tbl_ikhd_supel", on_update: :cascade
  add_foreign_key "tbl_pointambil", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_pointambil_kantor", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_rb_hutang", "tbl_imhd", column: "noretur", primary_key: "notransaksi", name: "tbl_rb_hutang_retur", on_update: :cascade
  add_foreign_key "tbl_rb_hutang", "tbl_imhd", column: "notrspot", primary_key: "notransaksi", name: "tbl_rb_hutang_trs", on_update: :cascade
  add_foreign_key "tbl_rj_piutang", "tbl_ikhd", column: "noretur", primary_key: "notransaksi", name: "tbl_rj_piutang_retur", on_update: :cascade
  add_foreign_key "tbl_rj_piutang", "tbl_ikhd", column: "notrspot", primary_key: "notransaksi", name: "tbl_rj_piutang_trs", on_update: :cascade
  add_foreign_key "tbl_supel", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_supplier_fk_mu"
  add_foreign_key "tbl_supel", "tbl_supel_subwil", column: "kdsubwil", primary_key: "kode", name: "tbl_supel_fk", on_update: :cascade
  add_foreign_key "tbl_supel", "tbl_supel_wil", column: "kdwilayah", primary_key: "kode", name: "tbl_supel_wilayah", on_update: :cascade
  add_foreign_key "tbl_tagihikdt", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_tagihikdt_item", on_update: :cascade
  add_foreign_key "tbl_tagihikdt", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_tagihikdt_satuan", on_update: :cascade
  add_foreign_key "tbl_tagihikdt", "tbl_tagihikhd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_tagihikdt_notransaksi", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_bank", column: "byr_debit_bank", primary_key: "kodebank", name: "tbl_tagihikhd_bank_kd", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_bank", column: "byr_kk_bank", primary_key: "kodebank", name: "tbl_tagihikhd_bank_kk", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_ikhd", column: "notransaksi_ko", primary_key: "notransaksi", name: "tbl_tagihkhd_notransaksi_ko", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_kantor", column: "kantordari", primary_key: "kodekantor", name: "tbl_tagihikhd_kantordari", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_tagihikhd_kantor", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_tagihikhd_mu", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_perkiraan", column: "acc_biaya_pot", primary_key: "kodeacc", name: "tbl_tagihikhd_biaya_pot", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_perkiraan", column: "acc_biayalain", primary_key: "kodeacc", name: "tbl_tagihikhd_biaya", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_perkiraan", column: "acc_debit", primary_key: "kodeacc", name: "tbl_tagihikhd_accdebit", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_perkiraan", column: "acc_dppesanan", primary_key: "kodeacc", name: "tbl_tagihikhd_accdppsn", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_perkiraan", column: "acc_hpp", primary_key: "kodeacc", name: "tbl_tagihikhd_hpp", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_perkiraan", column: "acc_kk", primary_key: "kodeacc", name: "tbl_tagihikhd_acckk", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_perkiraan", column: "acc_kredit", primary_key: "kodeacc", name: "tbl_tagihikhd_kredit", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_perkiraan", column: "acc_pajak", primary_key: "kodeacc", name: "tbl_tagihikhd_pajak", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_perkiraan", column: "acc_potongan", primary_key: "kodeacc", name: "tbl_tagihikhd_accpot", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_perkiraan", column: "acc_tunai", primary_key: "kodeacc", name: "tbl_tagihikhd_tunai", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_supel", column: "kodesupel", primary_key: "kode", name: "tbl_tagihikhd_supel", on_update: :cascade
  add_foreign_key "tbl_tagihikhd", "tbl_tagihikhd", column: "notrsretur", primary_key: "notransaksi", name: "tbl_tagihikhd_retur", on_update: :cascade
  add_foreign_key "tbl_tagihimdt", "tbl_item", column: "kodeitem", primary_key: "kodeitem", name: "tbl_tagihimdt_item", on_update: :cascade
  add_foreign_key "tbl_tagihimdt", "tbl_itemsatuan", column: "satuan", primary_key: "satuan", name: "tbl_tagihimdt_satuan", on_update: :cascade
  add_foreign_key "tbl_tagihimdt", "tbl_kantor", column: "sakantor", primary_key: "kodekantor", name: "tbl_tagihimdt_fk_kantor", on_update: :cascade
  add_foreign_key "tbl_tagihimdt", "tbl_tagihimhd", column: "notransaksi", primary_key: "notransaksi", name: "tbl_tagihimdt_tagihimhd", on_update: :cascade
  add_foreign_key "tbl_tagihimhd", "tbl_kantor", column: "kantortujuan", primary_key: "kodekantor", name: "tbl_tagihimhd_kantortjn", on_update: :cascade
  add_foreign_key "tbl_tagihimhd", "tbl_kantor", column: "kodekantor", primary_key: "kodekantor", name: "tbl_tagihimhd_kantor", on_update: :cascade
  add_foreign_key "tbl_tagihimhd", "tbl_matauang", column: "matauang", primary_key: "matauang", name: "tbl_tagihimhd_mu", on_update: :cascade
  add_foreign_key "tbl_tagihimhd", "tbl_perkiraan", column: "acc_biaya_pot", primary_key: "kodeacc", name: "tbl_tagihimhd_biaya_pot", on_update: :cascade
  add_foreign_key "tbl_tagihimhd", "tbl_perkiraan", column: "acc_biayalain", primary_key: "kodeacc", name: "tbl_tagihimhd_accbiaya", on_update: :cascade
  add_foreign_key "tbl_tagihimhd", "tbl_perkiraan", column: "acc_dppesanan", primary_key: "kodeacc", name: "tbl_tagihimhd_accdppsn", on_update: :cascade
  add_foreign_key "tbl_tagihimhd", "tbl_perkiraan", column: "acc_hpp", primary_key: "kodeacc", name: "tbl_tagihimhd_acchpp", on_update: :cascade
  add_foreign_key "tbl_tagihimhd", "tbl_perkiraan", column: "acc_kredit", primary_key: "kodeacc", name: "tbl_tagihimhd_acckredit", on_update: :cascade
  add_foreign_key "tbl_tagihimhd", "tbl_perkiraan", column: "acc_pajak", primary_key: "kodeacc", name: "tbl_tagihimhd_accpajak", on_update: :cascade
  add_foreign_key "tbl_tagihimhd", "tbl_perkiraan", column: "acc_potongan", primary_key: "kodeacc", name: "tbl_tagihimhd_accpot", on_update: :cascade
  add_foreign_key "tbl_tagihimhd", "tbl_perkiraan", column: "acc_tagihan", primary_key: "kodeacc", name: "tbl_tagihimhd_acctagihan", on_update: :cascade
  add_foreign_key "tbl_tagihimhd", "tbl_perkiraan", column: "acc_tunai", primary_key: "kodeacc", name: "tbl_tagihimhd_acctunai", on_update: :cascade
  add_foreign_key "tbl_tagihimhd", "tbl_supel", column: "kodesupel", primary_key: "kode", name: "tbl_tagihimhd_supel", on_update: :cascade
  add_foreign_key "tbl_tagihimhd", "tbl_tagihimhd", column: "notrsretur", primary_key: "notransaksi", name: "tbl_tagihimhd_retur", on_update: :cascade
  add_foreign_key "tbl_user", "tbl_kantor", column: "loginkantor", primary_key: "kodekantor", name: "tbl_user_loginkantor", on_update: :cascade
  add_foreign_key "tbl_user", "tbl_userg", column: "kelompok", primary_key: "kelompok", name: "tbl_user_kelompokacc", on_update: :cascade
  add_foreign_key "tbl_userakses", "tbl_userg", column: "klpakses", primary_key: "kelompok", name: "tbl_userakses_klp", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tbl_usercus_acc", "tbl_userg", column: "klpakses", primary_key: "kelompok", name: "tbl_usercus_acc_userg", on_update: :cascade, on_delete: :cascade
  add_foreign_key "users", "roles"
  add_foreign_key "work_schedules", "payrolls"
end
