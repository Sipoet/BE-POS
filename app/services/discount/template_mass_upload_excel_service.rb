class Discount::TemplateMassUploadExcelService < BaseService

  def execute_service
    @controller.send_file "#{Rails.root}/app/assets/excel/template_mass_upload_discount.xlsx"
  end

end
