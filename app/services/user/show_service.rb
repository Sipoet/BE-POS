class User::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    user = if @params[:username] =='current_user'
      current_user
    else
     User.find_by(username: @params[:username])
    end
    raise ApplicationService::RecordNotFound.new(@params[:username],User.name) if user.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(UserSerializer.new(user, options))
  end

  private

  def extract_params
    allowed_columns = User::TABLE_HEADER.map(&:name)
    allowed_fields = [:user, :role]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @included = result.included
    @fields = result.fields
  end
end
