require 'rails_helper'

RSpec.describe 'Accounts', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/account/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      get '/account/show'
      expect(response).to have_http_status(:success)
    end
  end
end
