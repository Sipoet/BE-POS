class RoleSerializer
  include JSONAPI::Serializer
  attributes :name

  has_many :column_authorizes, if: Proc.new { |record, params| params[:include].include?('column_authorizes') rescue false } do |record, params|
    record.column_authorizes.group_by(&:table).map do |table, columns|
      ColumnAuthorize.new(id:columns.first.id,table: table, column: columns.map(&:column).join(','))
    end
  end

  has_many :access_authorizes, if: Proc.new { |record, params| params[:include].include?('access_authorizes') rescue false } do |record, params|
    record.access_authorizes.group_by(&:controller).map do |controller, actions|
      AccessAuthorize.new(id:actions.first.id, controller: controller, action: actions.map(&:action).join(','))
    end
  end

  has_many :role_work_schedules, if: Proc.new { |record, params| params[:include].include?('role_work_schedules') rescue false } do |record, params|
    record.role_work_schedules.order(level: :asc, day_of_week: :asc, shift: :asc)
  end
end
