class UpdateAccessAuthorizeAction < ActiveRecord::Migration[7.1]
  def up
    list_roles = AccessAuthorize.where(action: %w[index show])
                                .pluck(:role_id, :controller)
    ApplicationRecord.transaction do
      list_roles.each do |(role_id, controller_name)|
        AccessAuthorize.create!(role_id: role_id, controller: controller_name, action: 'read')
      end
      AccessAuthorize.where(action: %w[index show]).delete_all
    end
    Cache.delete_namespace('column-authorizer')
    Cache.delete_namespace('role-')
  end

  def down
    list_roles = AccessAuthorize.where(action: 'read')
                                .pluck(:role_id, :controller)
    ApplicationRecord.transaction do
      list_roles.each do |(role_id, controller_name)|
        AccessAuthorize.insert_all!(
          [
            { role_id: role_id, controller: controller_name, action: 'index' },
            { role_id: role_id, controller: controller_name, action: 'show' }
          ]
        )
      end
      AccessAuthorize.where(action: 'read').delete_all
    end
  end
end
