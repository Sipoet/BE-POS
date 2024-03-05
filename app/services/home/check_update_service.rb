class Home::CheckUpdateService < ApplicationService

  APP_NAME  = {
    'android' => 'allegra-pos.apk',
    'windows' => 'allegra-pos.exe',
  }.freeze
  def execute_service
    permitted_params = params.permit(:client_version,:platform)
    client_version = permitted_params[:client_version].to_s
    platform = permitted_params[:platform].to_s.downcase
    if !['android','windows'].include? platform
      render_json({message:'not supported platform'},{status: :unprocessed_entity})
    end
    current_version = get_version(platform)
    Rails.logger.debug "#{platform} client_version: #{client_version}, current_version #{current_version}"
    if client_version.strip == current_version.strip
      render_json({message: 'app is up to date'})
      return
    end
    render_json({
      data:{
        version: current_version,
        filename: APP_NAME[platform]
      }
    })
  end

  private

  def get_version(platform)
    File.read("#{Rails.root}/app/assets/installer/#{platform}/version.txt")
  end
end
