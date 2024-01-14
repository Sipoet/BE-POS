class Home::SettingService < BaseService

  def execute_service
    menus = find_menus(@current_user.role)
    table_columns = find_table_columns(@current_user.role)
    render_json({data: {menus: menus, table_columns: table_columns}})
  end

  private

  def find_menus(role)
    # Role = Menu(role)
    []
  end

  def find_table_columns(role)
    [
      ItemSalesPercentageReport,
      Discount,
      ItemSalesPeriodReport
    ].each_with_object({}) do |klass,obj|
      obj[klass.name.camelize(:lower)] = table_names(klass)
    end
  end

  def table_names(klass)
    klass::TABLE_HEADER.each_with_object({}) do |column_name,obj|
      obj[column_name] = klass.human_attribute_name(column_name)
    end
  end
end
