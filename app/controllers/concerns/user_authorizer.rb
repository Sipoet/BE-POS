module UserAuthorizer
  SUPERADMIN = 'superadmin'.freeze
  extend ActiveSupport::Concern

  class AuthorizeChecker
    attr_reader :role
    def initialize(role)
      @role = role
    end


    def has_authorize?(controller_name, action)
      access = self.class.access_of(@role)
      return false if access[controller_name].blank?
      access[controller_name].include?(action)
    end

    def self.access_of(role)
      key = "role-#{role.id}-auth"
      cache = Cache.get(key)
      return JSON.parse(cache) if cache.present?
      value = decorate_access(role)
      Cache.set(key,value.to_json)
      return value
    end

    private

    def decorate_access(role)
      result = {}
      role.access_authorizes
          .group_by(&:controller)
          .each do |controller,access|
            result[controller] = access.map(&:action)
          end
      result
    end
  end

  class ForbiddenError < StandardError; end
  included do
    protected
    def authorize_role!(role)
      raise 'not a role' if !role.is_a?(Role)
      return if role.name == SUPERADMIN
      checker = AuthorizeChecker.new(role)
      raise ForbiddenError unless checker.has_authorize?(controller_name, action)
    end

    def allowed_columns(role, model_class)
      role.column_authorizes
          .where(table: model_class.name)
          .pluck(:column)
    end

    private

  end
end
