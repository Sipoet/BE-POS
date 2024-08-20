module NestedAttributesMatchup
  extend ActiveSupport::Concern
  included do
    def build_attributes(permitted_params_rows,attributes_records)
      return if permitted_params_rows.blank?
      permitted_params_rows.each do |line_params|
        attributes_records.build(line_params[:attributes])
      end
    end


    def edit_attributes(permitted_params_rows,attributes_records)
      return if permitted_params_rows.blank?
      records = attributes_records.index_by(&:id)
      permitted_params_rows.each do |line_params|
        record = records[line_params[:id].to_i]
        if record.present?
          record.attributes = line_params[:attributes]
          records.delete(line_params[:id].to_i)
        else
          record = attributes_records.build(line_params[:attributes])
        end
      end
      records.values.map(&:mark_for_destruction)
    end
  end
end
