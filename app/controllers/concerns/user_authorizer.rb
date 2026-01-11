module UserAuthorizer
  extend ActiveSupport::Concern

  class AuthorizeChecker
    attr_reader :role

    def initialize(role)
      @role = role
    end

    def has_authorize?(controller_name, action)
      access = role_access
      Rails.logger.debug "=====check authorize: #{controller_name} #{action}"
      return false if access[controller_name].blank?

      Rails.logger.debug "=====list authorize on #{controller_name} #{access[controller_name]}"
      access[controller_name].include?(action)
    end

    def role_access
      key = "role-#{role.id}-auth"
      cache = Cache.get(key)
      return JSON.parse(cache) if cache.present?

      value = decorate_access
      Cache.set(key, value.to_json)
      value
    end

    private

    def decorate_access
      result = {}
      role.access_authorizes
          .group_by(&:controller)
          .each do |controller, access|
            result[controller] = access.map(&:action)
          end
      result
    end
  end

  class ForbiddenError < StandardError; end
  included do
    protected

    def authorize_role!(role)
      raise 'not a role' unless role.is_a?(Role)
      return if role.name == Role::SUPERADMIN

      checker = AuthorizeChecker.new(role)
      raise ForbiddenError unless checker.has_authorize?(controller_name, action_name)
    end
  end
end
