class Users::SessionsController < Devise::SessionsController
  include RackSessionsFix
  respond_to :json

  def new
    render json: {code: 401, message:"Login failed."}, status: 401
  end
  private

  def respond_with(current_user, _opts = {})
  if current_user
    render json: {
        code: 200, message: 'Logged in successfully.',
        data: { user: UserSerializer.new(current_user).serializable_hash[:data][:attributes] }
    }, status: :ok
    else
      render json: {code: 401, message:"Login failed."}, status: 401
    end
  end
  def respond_to_on_destroy
    if request.headers['Authorization'].present?
      jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last, Rails.application.credentials.devise_jwt_secret_key!).first
      current_user = User.find(jwt_payload['sub'])
    end

    if current_user
      render json: {
        code: 200,
        message: 'Logged out successfully.'
      }, status: :ok
    else
      render json: {
        code: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end

  rescue JWT::ExpiredSignature => e
    render json: {
        code: 200,
        message: e.message,
      }, status: :ok
  end
end
