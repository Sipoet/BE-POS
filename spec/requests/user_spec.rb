require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:user) { create(:admin) }
  context 'CRUD' do
    before :each do
      superadmin = create(:superadmin)
      @headers = login(superadmin)
    end

    describe 'GET /index' do
      it 'should success' do
        get users_path, headers: @headers
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /show' do
      it 'should display user' do
        get user_path(user.username), headers: @headers
        expect(response).to have_http_status(:success)
        result = JSON.parse(response.body, symbolize_names: true)
        data = result[:data]
        expect(data[:id]).to eq(user.id.to_s)
        expect(data[:type]).to eq('user')
        attributes = data[:attributes]
        expect(attributes[:username]).to eq(user.username)
        expect(attributes[:email]).to eq(user.email)
      end
    end

    describe 'POST /users' do
      it 'should create user' do
        post users_path, headers: @headers, params: { user: {
          username: 'user1',
          email: 'user1@example.com',
          password: 'password',
          role: 'admin',
          password_confirmation: 'password'
        } }.to_json
        expect(response).to have_http_status(:created)
        result = JSON.parse(response.body, symbolize_names: true)
        data = result[:data]
        user = User.find(data[:id])
        expect(data[:type]).to eq('user')
        attributes = data[:attributes]
        expect(attributes[:username]).to eq(user.username)
        expect(attributes[:email]).to eq(user.email)
      end
    end

    describe 'PUT /users/:username' do
      it 'should update user' do
        user = create(:admin)
        old_username = user.username
        patch user_path(user.username), headers: @headers, params: { user: {
          username: 'user2',
          role: 'admin',
          email: 'user2@example.com',
          password: 'password',
          password_confirmation: 'password'
        } }.to_json
        expect(response).to have_http_status(:success)
        result = JSON.parse(response.body, symbolize_names: true)
        data = result[:data]
        expect(data[:id]).to eq(user.id.to_s)

        expect(data[:type]).to eq('user')
        attributes = data[:attributes]
        expect(attributes[:username]).to eq(old_username)
        expect(attributes[:email]).to eq('user2@example.com')
      end
    end

    it 'should delete user' do
      user = create(:admin)
      delete user_path(user.username), headers: @headers
      expect(response).to have_http_status(:success), response.body
      user = User.find_by(username: user.username)
      expect(user).to be_nil, 'user should be deleted'
    end
  end

  describe 'authorization' do
    it 'superadmin can accessed' do
      user = create(:superadmin)
      headers = login(user)
      get users_path, headers: headers
      expect(response).to have_http_status(:success)
    end

    it 'admin can accessed' do
      user = create(:admin)
      headers = login(user)
      get users_path, headers: headers
      expect(response).to have_http_status(:success)
    end

    it 'cashier can not accessed' do
      user = create(:cashier)
      headers = login(user)
      get users_path, headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  def login(user)
    post user_session_path, params: { "user": {
      "username": user.username,
      "password": user.password
    } }
    authorization = response.headers['Authorization']
    {
      'Authorization' => authorization,
      'Content-Type' => 'application/json'
    }
  end
end
