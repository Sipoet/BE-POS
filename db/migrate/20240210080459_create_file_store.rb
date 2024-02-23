class CreateFileStore < ActiveRecord::Migration[7.1]
  def change
    create_table :file_stores do |t|
      t.string :code, null: false, index: {unique: true}
      t.string :filename, null: false
      t.binary :file, null: false
      t.string :description
      t.timestamps
    end
  end
end
