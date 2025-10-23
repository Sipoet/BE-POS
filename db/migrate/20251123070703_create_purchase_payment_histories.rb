class CreatePurchasePaymentHistories < ActiveRecord::Migration[7.1]
  def up
    ActiveRecord::Base.connection.execute <<~SQL
      CREATE VIEW purchase_payment_histories AS(
        SELECT
          iddetail AS id,
          tbl_imhd.notransaksi AS purchase_code,
          tbl_pesanhd.notransaksi AS purchase_order_code,
          tbl_byrhutanghd.tanggal AS transaction_at,
          tbl_imhd.tanggal AS stock_arrived_at,
          tbl_pesanhd.tanggal AS invoiced_at,
          tbl_byrhutanghd.keterangan AS description,
          tbl_byrhutanghd.kodesupel AS supplier_code,
          tbl_byrhutanghd.acc_bayar AS payment_account_code,
          tbl_byrhutangdt.notransaksi AS code,
          tbl_byrhutangdt.krd_jml_byr AS payment_amount,
          tbl_byrhutangdt.krd_jml_pot AS discount_amount,
          tbl_imhd.totalakhir AS grand_total,
          tbl_byrhutangdt.jmlkredit AS debt_total,
          tbl_byrhutangdt.krd_total - tbl_byrhutangdt.krd_jml_byr AS debt_left
        FROM tbl_byrhutangdt
        INNER JOIN tbl_byrhutanghd on tbl_byrhutanghd.notransaksi = tbl_byrhutangdt.notransaksi
        LEFT OUTER JOIN tbl_imhd on tbl_byrhutangdt.notrsmasuk = tbl_imhd.notransaksi
        LEFT OUTER JOIN tbl_pesanhd on tbl_pesanhd.notransaksi = tbl_imhd.notrsorder
      )
    SQL
  end

  def down
    ActiveRecord::Base.connection.execute <<-SQL
      DROP VIEW IF EXISTS purchase_payment_histories;
    SQL
  end
end
