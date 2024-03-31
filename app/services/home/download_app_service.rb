class Home::DownloadAppService < ApplicationService

  APP_EXT  = {
    'android' => 'apk',
    'windows' => 'exe',
  }.freeze

  def execute_service
    permitted_params = params.permit(:platform)
    platform = permitted_params[:platform].to_s
    if !['android','windows'].include? platform
      render_json({message:'not supported platform'},{status: :unprocessed_entity})
    else
      file_path = Dir["#{Rails.root}/app/assets/installer/#{platform}/*.#{APP_EXT[platform]}"].first
      @controller.send_file file_path
    end


  end

end
