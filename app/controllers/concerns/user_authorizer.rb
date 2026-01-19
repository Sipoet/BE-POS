module UserAuthorizer
  extend ActiveSupport::Concern

  class AuthorizeChecker
    attr_reader :role_id

    READ_ACTION = %w[index show]

    def initialize(role_id)
      @role_id = role_id
    end

    def has_authorize?(controller_name, action)
      action = 'read' if READ_ACTION.include? action
      @access ||= role_access
      Rails.logger.debug "=====check authorize: #{controller_name} #{action}"
      return false if @access[controller_name].blank?

      Rails.logger.debug "=====list authorize on #{controller_name} #{@access[controller_name]}"
      @access[controller_name][action] == true
    end

    def role_access
      key = "role-#{@role_id}-auth"
      cache = Cache.get(key)
      return JSON.parse(cache) if cache.present?

      value = decorate_access
      Cache.set(key, value.to_json)
      value
    end

    private

    def decorate_access
      result = {}
      AccessAuthorize.where(role_id: @role_id)
                     .group_by(&:controller)
                     .each do |controller, access|
                       result[controller] = access.map { |auth| [auth.action, true] }.to_h
      end
      result
    end
  end

  class ForbiddenError < StandardError; end
  included do
    protected

    def authorize_role!(role_id)
      raise 'not a role' if role_id.nil?
      return if Role.superadmin?(role_id)

      checker = AuthorizeChecker.new(role_id)
      raise ForbiddenError unless checker.has_authorize?(controller_path, action_name)
    end
  end
end
