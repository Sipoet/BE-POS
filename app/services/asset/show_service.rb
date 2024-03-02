class Asset::ShowService < ApplicationService

  def execute_service
    store = FileStore.find_by(code: params[:code])
    raise RecordNotFound.new(params[:code], 'file') if store.nil?
    @controller.send_data store.file, filename: store.filename, disposition: 'inline'
    # insert code here
  end

end
