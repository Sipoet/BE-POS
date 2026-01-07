class Item::UpdateService < ApplicationService
  def execute_service
    item = Ipos::Item.find(params[:code])
    raise RecordNotFound.new(params[:code], Ipos::Item.model_name.human) if item.nil?

    if record_save?(item)
      render_json(Ipos::ItemSerializer.new(item, { fields: @fields, include: %w[supplier item_type brand] }))
    else
      render_error_record(item)
    end
  end

  def record_save?(item)
    ApplicationRecord.transaction do
      update_attribute!(item)
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def update_attribute!(item)
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Item)
    @fields = { item: @table_definitions.column_names }
    permitted_column = permitted_column_names(Ipos::Item)
    if permitted_column == ALL_COLUMN
      permitted_column = %i[code name description cogs sell_price supplier_code item_type_name brand_name]
    end
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(*permitted_column)
    item.update!(permitted_params)
  end
end
