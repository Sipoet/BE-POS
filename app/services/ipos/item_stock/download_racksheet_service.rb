# frozen_string_literal: true

class Ipos::ItemStock::DownloadRacksheetService < ApplicationService
  def execute_service
    reports = Ipos::ItemStock.all.order(item_code: :asc)
    file = generate_file(reports)
    @controller.send_file file
  end

  private

  @@column_definitions = [
    Datatable::TableColumn.new(:item_code, { humanize_name: Ipos::ItemStock.human_attribute_name(:item_code), excel_width: 35 },
                               Ipos::ItemStock),
    Datatable::TableColumn.new(:location_code, { humanize_name: Ipos::ItemStock.human_attribute_name(:location_code) },
                               Ipos::ItemStock),
    Datatable::TableColumn.new(:rack, { humanize_name: Ipos::ItemStock.human_attribute_name(:rack) },
                               Ipos::ItemStock)

  ]
  def generate_file(reports)
    generator = ExcelGenerator.new
    generator.add_column_definitions(@@column_definitions)
    generator.add_data(reports)
    generator.generate("item-location-racksheet-#{timestamp}")
  end

  def timestamp
    Time.now.strftime('%y%m%d%H%M%S')
  end
end
