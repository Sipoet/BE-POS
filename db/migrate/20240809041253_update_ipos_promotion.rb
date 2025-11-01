class UpdateIposPromotion < ActiveRecord::Migration[7.1]
  def up
    add_column 'tbl_itemdisp', :discount_id, :integer
    add_foreign_key 'tbl_itemdisp', :discounts, column: :discount_id
    seed_discount_id
  end

  def down
    remove_column 'tbl_itemdisp', :discount_id
  end

  private

  def seed_discount_id
    puts 'seed discount id begin'
    Discount.all.order(weight: :asc).each do |discount|
      Ipos::Promotion
        .where('iddiskon ilike ?', "%_#{discount.code}%")
        .update_all(discount_id: discount.id)
    end
    puts 'seed discount id done'
  end
end
