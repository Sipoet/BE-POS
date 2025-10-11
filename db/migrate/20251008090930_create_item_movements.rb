class CreateItemMovements < ActiveRecord::Migration[7.1]
  def up
    ActiveRecord::Base.connection.execute <<-SQL
      CREATE MATERIALIZED VIEW item_movements AS (
        SELECT
          subquery.iddetail AS id,
          subquery.tanggal AS transaction_date,
          subquery.tipe AS ipos_type,
          subquery.movement_type,
          tbl_item.kodeitem AS item_code,
          tbl_item.supplier1 AS supplier_code,
          tbl_item.jenis AS item_type_name,
          tbl_item.merek AS brand_name,
          jumlahdasar AS quantity
        FROM(
          SELECT
            iddetail,
            tanggal,
            tipe,
            1 AS movement_type,
            kodeitem,
            round(jumlahdasar,1) AS jumlahdasar
          FROM tbl_item_im
          WHERE tipe IN ('BL','IM','RJ','KI','RKI')
          UNION
          SELECT
            iddetail,
            tanggal,
            tipe,
            0 AS movement_type,
            kodeitem,
            round(jumlahdasar * -1,1) AS jumlahdasar
          FROM tbl_item_ik
          WHERE tipe IN ('KSR','JL','IK','RB','KK','RKI')
          UNION
          SELECT
            iddetailtrs AS iddetail,
            tanggal,
            'SA' AS tipe,
            1 AS movement_type,
            kodeitem,
            round(jumlah * jmlkonversi,1) AS jumlahdasar
          FROM tbl_item_sa
        )subquery
        INNER JOIN tbl_item ON tbl_item.kodeitem = subquery.kodeitem
        ORDER BY transaction_date ASC, item_code ASC
      );
      CREATE UNIQUE INDEX u_idx_imov1
        ON item_movements (id);
      CREATE INDEX idx_imov2
        ON item_movements (transaction_date,movement_type);
      CREATE INDEX idx_imov3
        ON item_movements (transaction_date,item_code);

    SQL
  end

  def down
    ActiveRecord::Base.connection.execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS item_movements;
    SQL
  end
end
