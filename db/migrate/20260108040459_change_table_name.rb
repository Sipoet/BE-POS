class ChangeTableName < ActiveRecord::Migration[7.1]
  def up
    ApplicationRecord.transaction do
      ColumnAuthorize.all.each do |line|
        line.update!(table: line.table.classify)
      end
    end
  end

  def down
    ApplicationRecord.transaction do
      ColumnAuthorize.all.each do |line|
        line.update!(table: line.table.underscore)
      end
    end
  end
end
