class AddIndexItemPromotion < ActiveRecord::Migration[7.1]
  def change
    add_index :tbl_itemdispdt, %i[kodeitem iddiskon], unique: true
  end
end
