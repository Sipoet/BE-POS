require 'yaml'
require 'net/http'
class Home::CheckUpdateService < ApplicationService
  APP_NAME = {
    'android' => 'allegra-pos.apk',
    'windows' => 'allegra-pos.exe'
  }.freeze
  def execute_service
    permitted_params = params.permit(:client_version, :platform)
    client_version = permitted_params[:client_version].to_s
    platform = permitted_params[:platform].to_s.downcase
    unless %w[android windows].include? platform
      render_json({ message: 'not supported platform' }, { status: :unprocessed_entity })
    end
    current_version = get_version(platform)
    Rails.logger.debug "#{platform} client_version: #{client_version}, current_version #{current_version}"
    if version_uptodated?(client_version.strip, current_version.strip)
      render_json({ message: 'app is up to date' })
      return
    end
    render_json({
                  data: {
                    version: current_version,
                    filename: APP_NAME[platform]
                  }
                })
  end

  private

  def get_version(_platform)
    uri = URI('https://raw.githubusercontent.com/Sipoet/FE-POS/main/pubspec.yaml')
    yaml_string = Net::HTTP.get(uri)
    data = begin
      YAML.load(yaml_string)
    rescue StandardError
      {}
    end
    data['version']
  end

  def version_uptodated?(client_version, current_version)
    client_version_level = client_version.split('.')
    current_version_level = current_version.split('.')
    client_version_level.each.with_index do |level, index|
      next if level.to_i == current_version_level[index].to_i

      return level.to_i > current_version_level[index].to_i
    end
    true
  end
end
