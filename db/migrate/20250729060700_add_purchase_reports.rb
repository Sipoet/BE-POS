class AddPurchaseReports < ActiveRecord::Migration[7.1]
  def up
    ApplicationRecord.connection.execute "
    DROP VIEW IF EXISTS purchase_reports;
    CREATE MATERIALIZED VIEW IF NOT EXISTS purchase_reports AS (
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
        COALESCE(round(tbl_pesanhd.totalitem, 2), 0::numeric) AS order_item_total,
        COALESCE(round(tbl_pesanhd.totalakhir, 2), 0::numeric) AS order_grand_total,
        COALESCE(pret.return_item_total, 0::numeric) AS return_item_total,
        COALESCE(pret.return_amount_total, 0::numeric) AS return_amount_total,
        payer.last_paid_date,
        purchase.totalakhir - COALESCE(pret.return_amount_total, 0::numeric) AS grandtotal,
        purchase.dppesanan + COALESCE(payer.paid_amount, 0::numeric) AS paid_amount,
        purchase.totalakhir - COALESCE(pret.return_amount_total, 0::numeric) - (purchase.dppesanan + COALESCE(payer.paid_amount, 0::numeric)) AS debt_amount,
          CASE
              WHEN (purchase.dppesanan + COALESCE(payer.paid_amount, 0::numeric)) = 0::numeric THEN 'no_paid'::text
              WHEN (purchase.totalakhir - COALESCE(pret.return_amount_total, 0::numeric) - (purchase.dppesanan + COALESCE(payer.paid_amount, 0::numeric))) = 0::numeric THEN 'paid'::text
              WHEN (purchase.totalakhir - COALESCE(pret.return_amount_total, 0::numeric) - (purchase.dppesanan + COALESCE(payer.paid_amount, 0::numeric))) < 0::numeric THEN 'over_paid'::text
              ELSE 'half_paid'::text
          END AS status
        FROM ( SELECT tbl_imhd.notransaksi,
            tbl_imhd.kodekantor,
            tbl_imhd.kantortujuan,
            tbl_imhd.tanggal,
            tbl_imhd.tipe,
            tbl_imhd.notrsorder,
            tbl_imhd.kodesupel,
            tbl_imhd.matauang,
            tbl_imhd.rate,
            tbl_imhd.keterangan,
            tbl_imhd.totalitem,
            tbl_imhd.totalitempesan,
            tbl_imhd.subtotal,
            tbl_imhd.potfaktur,
            tbl_imhd.pajak,
            tbl_imhd.biayalain,
            tbl_imhd.prpajak,
            tbl_imhd.dppesanan,
            tbl_imhd.jmldeposit,
            tbl_imhd.totalakhir,
            tbl_imhd.carabayar,
            tbl_imhd.jmltunai,
            tbl_imhd.jmlkredit,
            tbl_imhd.potnomfaktur,
            tbl_imhd.byr_krd_jt,
            tbl_imhd.byr_krd_no,
            tbl_imhd.krd_jml_pot,
            tbl_imhd.krd_jml_byr,
            tbl_imhd.ppn,
            tbl_imhd.notrsretur,
            tbl_imhd.acc_potongan,
            tbl_imhd.acc_pajak,
            tbl_imhd.acc_biayalain,
            tbl_imhd.acc_tunai,
            tbl_imhd.acc_kredit,
            tbl_imhd.acc_hpp,
            tbl_imhd.acc_deposit,
            tbl_imhd.acc_dppesanan,
            tbl_imhd.acc_biaya_pot,
            tbl_imhd.acc_beda_cab,
            tbl_imhd.user1,
            tbl_imhd.user2,
            tbl_imhd.dateupd,
            tbl_imhd.biaya_msk_total,
            tbl_imhd.compname,
            tbl_imhd.shiftkerja,
            tbl_imhd.tanggal_sa,
            tbl_imhd.bc_trf_sts,
            tbl_imhd.tottagihki,
            tbl_imhd.totitemretur,
            tbl_imhd.swt_sa_sts,
            tbl_imhd.prpotfaktur,
            tbl_imhd.nofp,
            tbl_imhd.status_online,
            tbl_imhd.compname_online,
            tbl_imhd.user_online,
            tbl_imhd.mode_retur
           FROM tbl_imhd
          WHERE tbl_imhd.tipe::text = 'BL'::text) purchase
     LEFT OUTER JOIN tbl_pesanhd ON tbl_pesanhd.notransaksi::text = purchase.notrsorder::text
     LEFT OUTER JOIN ( SELECT tbl_imdt.notrsretur AS notransaksi,
            round(sum(tbl_imdt.jmlkonversi * tbl_imdt.jumlah), 2) AS return_item_total,
            round(sum(tbl_imdt.total), 2) AS return_amount_total
           FROM tbl_imdt
             JOIN tbl_imhd ON tbl_imhd.notransaksi::text = tbl_imdt.notransaksi::text
          WHERE tbl_imhd.tipe::text = 'RB'::text
          GROUP BY tbl_imdt.notrsretur) pret ON pret.notransaksi::text = purchase.notransaksi::text
     LEFT OUTER JOIN ( SELECT tbl_byrhutangdt.notrsmasuk AS notransaksi,
            sum(tbl_byrhutangdt.krd_jml_byr) AS paid_amount,
            max(tbl_byrhutanghd.tanggal) AS last_paid_date
          FROM tbl_byrhutangdt
          INNER JOIN tbl_byrhutanghd ON tbl_byrhutangdt.notransaksi::text = tbl_byrhutanghd.notransaksi::text
          WHERE tbl_byrhutangdt.tipe::text = 'BL'::text
          GROUP BY tbl_byrhutangdt.notrsmasuk) payer ON payer.notransaksi::text = purchase.notransaksi::text
    );
    CREATE UNIQUE INDEX u_idx_purchase_reports
    ON purchase_reports (code);
    "
  end

  def down
    ActiveRecord::Base.connection.execute "
    DROP INDEX IF EXISTS u_idx_purchase_reports;
    DROP MATERIALIZED VIEW IF EXISTS purchase_reports;
    "
  end
end
