require 'net/http'
module SessionHelper

  def get_auth_token(user)
    post '/login', params:{
      "user"=>{
        "username"=> user.username,
        "password"=> user.password
      }
    }
    return response.headers['Authorization']
    # "Bearer #{user.jti}"
  end

end
