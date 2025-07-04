class CreateProductTags < ActiveRecord::Migration[7.1]
  def change
    create_table :product_tags do |t|
      t.references :product, null: false
      t.references :tag, null: false
      t.timestamps
    end
  end
end
