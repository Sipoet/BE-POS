require 'rails_helper'

RSpec.describe 'Sales', type: :request do
  describe 'GET /transaction_report' do
    before :each do
      login!
    end
    it 'should success' do
      get transaction_report_sales_path, params: { start_time: DateTime.now.iso8601, end_time: DateTime.now.iso8601 },
                                         headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  def login!
    user = create(:superadmin)
    post user_session_path, params: { "user": {
      "username": user.username,
      "password": user.password
    } }
    @authorization = response.headers['Authorization']
  end

  def headers
    {
      'Authorization' => @authorization,
      'Content-Type' => 'application/json'
    }
  end
end
