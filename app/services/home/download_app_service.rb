class Home::DownloadAppService < ApplicationService
  APP_EXT = {
    'android' => 'apk',
    'windows' => 'exe'
  }.freeze

  def execute_service
    permitted_params = params.permit(:platform)
    platform = permitted_params[:platform].to_s
    if !%w[android windows].include? platform
      render_json({ message: 'not supported platform' }, { status: :unprocessed_entity })
    else
      @controller.redirect_to "https://raw.githubusercontent.com/Sipoet/FE-POS/main/src/#{platform}/Output/allegra-pos.#{APP_EXT[platform]}"
    end
  end
end
