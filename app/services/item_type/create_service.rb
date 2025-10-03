class ItemType::CreateService < ApplicationService

  def execute_service
    item_type = Ipos::ItemType.new
    if record_save?(item_type)
      render_json(Ipos::ItemTypeSerializer.new(item_type,fields:@fields),{status: :created})
    else
      render_error_record(item_type)
    end
  end

  def record_save?(item_type)
    ApplicationRecord.transaction do
      update_attribute(item_type)
      item_type.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def update_attribute(item_type)
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::ItemType)
    @fields = {item_type: @table_definitions.allowed_columns}
    Rails.logger.debug @fields
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(@table_definitions.allowed_edit_columns)
    item_type.attributes = permitted_params
  end
end
