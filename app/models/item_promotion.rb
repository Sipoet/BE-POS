class ItemPromotion < ApplicationRecord
  self.table_name = "tbl_itemdispdt"
  self.primary_key = ['kodeitem','iddiskon']
  default_scope { order(iddiskon: :asc) }
  belongs_to :promotion, class_name: "Promotion", foreign_key: "iddiskon"

  def self.delete_by_iddiskon(iddiskon)
    ids = *iddiskon
    ids = sanitize_sql(['in (?)', ids])
    connection.execute """
      DELETE
      FROM #{table_name}
      USING #{Promotion.table_name}
      WHERE #{Promotion.table_name}.iddiskon #{ids}
    """
  end
end
