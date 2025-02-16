class CreatePurchaseReport < ActiveRecord::Migration[7.1]
  def up
    ActiveRecord::Base.connection.execute """
      CREATE VIEW purchase_reports AS (
        SELECT
          purchase.notransaksi AS code,
          purchase.kodesupel AS supplier_code,
          purchase.tanggal AS purchase_date,
          purchase.byr_krd_jt AS due_date,
          purchase.totalitem AS purchase_item_total,
          purchase.subtotal AS purchase_subtotal,
          purchase.potnomfaktur AS header_discount_amount,
          purchase.biayalain AS purchase_other_cost,
          purchase.totalakhir AS purchase_grand_total,
          tbl_pesanhd.tanggal AS order_date,
          tbl_pesanhd.tanggalkirim AS shipping_date,
          COALESCE(ROUND(tbl_pesanhd.totalitem,2),0) AS order_item_total,
          COALESCE(ROUND(tbl_pesanhd.totalakhir,2),0) AS order_grand_total,
          COALESCE(pret.return_item_total,0) AS return_item_total,
          COALESCE(pret.return_amount_total,0) AS return_amount_total,
          payer.last_paid_date,
          purchase.totalakhir - COALESCE(pret.return_amount_total,0) AS grandtotal,
          purchase.dppesanan + COALESCE(payer.paid_amount,0) AS paid_amount,
          purchase.totalakhir - COALESCE(pret.return_amount_total,0) - (purchase.dppesanan + COALESCE(payer.paid_amount,0)) AS debt_amount,
          (CASE WHEN purchase.dppesanan + COALESCE(payer.paid_amount,0) = 0 then 'no_paid'
          WHEN purchase.totalakhir - COALESCE(pret.return_amount_total,0) - (purchase.dppesanan + COALESCE(payer.paid_amount,0)) = 0 then 'paid'
          WHEN purchase.totalakhir - COALESCE(pret.return_amount_total,0) - (purchase.dppesanan + COALESCE(payer.paid_amount,0)) < 0 then 'over_paid'
          ELSE 'half_paid' END) as status
        FROM (
          SELECT *
          FROM tbl_imhd
          WHERE tipe = 'BL'
        ) purchase
        left outer join tbl_pesanhd on tbl_pesanhd.notransaksi = purchase.notrsorder
        left outer join (
          SELECT
            tbl_imdt.notrsretur AS notransaksi,
            ROUND(SUM(tbl_imdt.jmlkonversi * tbl_imdt.jumlah),2) AS return_item_total,
            ROUND(SUM(tbl_imdt.total),2) AS return_amount_total
            FROM tbl_imdt
            INNER JOIN tbl_imhd on tbl_imhd.notransaksi = tbl_imdt.notransaksi
          WHERE
            tbl_imhd.tipe = 'RB'
          GROUP BY tbl_imdt.notrsretur
        )pret on pret.notransaksi = purchase.notransaksi
        left outer join(
          SELECT
            notrsmasuk AS notransaksi,
            SUM(krd_jml_byr) AS paid_amount,
            MAX(tbl_byrhutanghd.tanggal) AS last_paid_date
          FROM tbl_byrhutangdt
          INNER JOIN tbl_byrhutanghd on tbl_byrhutangdt.notransaksi = tbl_byrhutanghd.notransaksi
          WHERE tbl_byrhutangdt.tipe = 'BL'
          GROUP BY notrsmasuk
        )payer on payer.notransaksi = purchase.notransaksi
      )
    """
  end

  def down
    ActiveRecord::Base.connection.execute('DROP VIEW IF EXISTS purchase_reports')

  end
end
