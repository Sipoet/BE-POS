class AddExpiredAtToFileStore < ActiveRecord::Migration[7.1]
  def change
    add_column :file_stores, :expired_at, :datetime
    remove_column :employees, :image_id
    add_column :employees, :image_code, :string
  end
end
