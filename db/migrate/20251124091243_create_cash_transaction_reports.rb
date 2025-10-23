# frozen_string_literal: true

class CreateCashTransactionReports < ActiveRecord::Migration[7.1]
  def up
    ActiveRecord::Base.connection.execute <<~SQL
      CREATE VIEW cash_transaction_reports AS(
        SELECT
          tbl_acckasdt.iddetail AS id,
          tbl_acckasdt.notransaksi AS code,
          tbl_acckasdt.jumlah AS payment_amount,
          case when tbl_acckashd.tipe =  'KASO' then
            'cash_out'
          when tbl_acckashd.tipe = 'KASI' then
            'cash_in'
          when tbl_acckashd.tipe = 'KASTR' then
            'cash_transfer'
          else
            null
          end AS transaction_type,
          tbl_acckasdt.dateupd AS updated_at,
          tbl_acckasdt.kodeacc AS detail_account_code,
          tbl_acckasdt.keterangan AS description,
          tbl_acckashd.kodeacc AS payment_account_code,
          tbl_acckashd.tanggal AS transaction_at
        FROM tbl_acckasdt
        INNER JOIN tbl_acckashd on tbl_acckashd.notransaksi = tbl_acckasdt.notransaksi
      )
    SQL
  end

  def down
    ActiveRecord::Base.connection.execute <<-SQL
      DROP VIEW IF EXISTS cash_transaction_reports;
    SQL
  end
end
