class UpdateRole < ActiveRecord::Migration[7.1]
  def change
    add_column :role_work_schedules, :is_flexible, :boolean, null: false, default: false
  end
end
