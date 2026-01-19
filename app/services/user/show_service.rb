class User::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    user = User.find_by(username: @params[:username])
    raise ApplicationService::RecordNotFound.new(@params[:username], User.name) if user.nil?

    if current_user.id == user.id && !@fields.nil?
      @fields[:user] ||= []
      @fields[:user] += %i[username email]
      @fields[:user].uniq!
    end
    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    Rails.logger.debug "===options #{options}"
    render_json(UserSerializer.new(user, options))
  end

  private

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(User)
    allowed_includes = %i[user role]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: User)
  end
end
