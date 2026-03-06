# frozen_string_literal: true

class Ipos::ItemStock::UploadRacksheetService < ApplicationService
  def execute_service
    sheet = read_excel!(params[:file])
    check_sheet_format!(sheet)
    convert_to_item_stocks(sheet)
    render_json({ message: 'success' })
  rescue ValidationError => e
    render_json({ message: "Error: #{e.message}", errors: [e.message] }, { status: :conflict })
  end

  private

  def read_excel!(file)
    workbook = Xsv.open(file.path)
    workbook.first
  end

  def check_sheet_format!(sheet)
    header = sheet.to_a.first
    if header[0].to_s != Ipos::ItemStock.human_attribute_name(:item_code)
      Rails.logger.error 'first column must filled with item'
      raise ValidationError.new('first column must filled with item')
    end
    if header[1].to_s != Ipos::ItemStock.human_attribute_name(:location_code)
      Rails.logger.error 'second column must filled with location'
      raise ValidationError.new('second column must filled with location')
    end
    return unless header[2].to_s != Ipos::ItemStock.human_attribute_name(:rack)

    Rails.logger.error 'third column must filled with rack'
    raise ValidationError.new('third column must filled with rack')
  end

  def convert_to_item_stocks(sheet)
    sheet.to_a[1..-1].each do |rows|
      item_code, location_code, rack = rows.map(&:to_s)
      break if item_code.blank? && location_code.blank?

      item_stock = Ipos::ItemStock.find_or_initialize_by(item_code: item_code, location_code: location_code)
      # skip if item code or location not valid
      next unless item_stock.valid?

      item_stock.rack = rack
      item_stock.save
    end
  end
end
