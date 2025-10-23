class UpdateAccessAuthorizeAction < ActiveRecord::Migration[7.1]
  IPOS_CONTROLLER = [
    ['items', 'ipos/items'], ['suppliers', 'ipos/suppliers'],
    ['item_types', 'ipos/item_types'], ['banks', 'ipos/banks'],
    ['brands', 'ipos/brands'], ['sales', 'ipos/sales'],
    ['sale_items', 'ipos/sale_items'], ['transfer_items', 'ipos/transfer_items'],
    ['purchases', 'ipos/purchases'], ['purchase_orders', 'ipos/purchase_orders'], ['purchase_returns', 'ipos/purchase_returns'],
    ['purchase_items', 'ipos/purchase_items'], ['transfers', 'ipos/transfers'],
    ['accounts', 'ipos/accounts'], ['customer_groups', 'ipos/customer_groups']
  ]
  def up
    list_roles = AccessAuthorize.where(action: %w[index show])
                                .pluck(:role_id, :controller)
    ApplicationRecord.transaction do
      list_roles.each do |(role_id, controller_name)|
        new_controller_name = controller_name
        AccessAuthorize.create!(role_id: role_id, controller: controller_name, action: 'read')
      end
      AccessAuthorize.where(action: %w[index show]).delete_all
    end
    IPOS_CONTROLLER.each do |(old_controller, new_controller)|
      AccessAuthorize.where(controller: old_controller).update_all(controller: new_controller)
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
    IPOS_CONTROLLER.each do |(old_controller, new_controller)|
      AccessAuthorize.where(controller: new_controller).update_all(controller: old_controller)
    end
  end
end
