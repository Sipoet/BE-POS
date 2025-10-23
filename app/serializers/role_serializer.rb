class RoleSerializer
  include JSONAPI::Serializer
  attributes :name, :created_at, :updated_at

  has_many :column_authorizes, if: proc { |_record, params|
    begin
      params[:include].include?('column_authorizes')
    rescue StandardError
      false
    end
  } do |record, _params|
    record.column_authorizes.group_by(&:table).map do |table, columns|
      ColumnAuthorize.new(id: columns.first.id, table: table, column: columns.map(&:column).join(','))
    end
  end

  has_many :access_authorizes, if: proc { |_record, params|
    begin
      params[:include].include?('access_authorizes')
    rescue StandardError
      false
    end
  } do |record, _params|
    record.access_authorizes.group_by(&:controller).map do |controller, actions|
      AccessAuthorize.new(id: actions.first.id, controller: controller, action: actions.map(&:action).join(','))
    end
  end

  has_many :role_work_schedules, if: proc { |_record, params|
    begin
      params[:include].include?('role_work_schedules')
    rescue StandardError
      false
    end
  } do |record, _params|
    record.role_work_schedules.order(level: :asc, day_of_week: :asc, shift: :asc)
  end
end
