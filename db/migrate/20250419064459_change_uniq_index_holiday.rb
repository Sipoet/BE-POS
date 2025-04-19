class ChangeUniqIndexHoliday < ActiveRecord::Migration[7.1]
  def change
    remove_index :holidays, :date
    add_index :holidays, [:date, :religion], unique: true, name:'hlday_uniq_idx'
  end
end
