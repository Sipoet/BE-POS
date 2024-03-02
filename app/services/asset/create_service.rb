class Asset::CreateService < ApplicationService

  def execute_service
    file = params.permit(:file)[:file]
    file_store = FileStore.new(
      code: SecureRandom.uuid,
      filename: file.original_filename,
      file: file.read,
      expired_at: Date.tomorrow.end_of_day)
    if file_store.save
      render_json(FileStoreSerializer.new(file_store),{status: :created})
    else
      render_error_record(file_store)
    end
  end

end
